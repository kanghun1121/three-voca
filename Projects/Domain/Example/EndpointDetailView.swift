import Dependencies
import DomainInterface
import SwiftUI

struct EndpointDetailView: View {
    enum Endpoint {
        case homeOverview
        case sessionDetail
        case wordDetail

        var title: String {
            switch self {
            case .homeOverview: "fetchHomeOverview()"
            case .sessionDetail: "fetchSessionDetail(id:)"
            case .wordDetail: "fetchWordDetail(id:)"
            }
        }

        var hasIdParam: Bool {
            switch self {
            case .homeOverview: false
            case .sessionDetail, .wordDetail: true
            }
        }
    }

    let endpoint: Endpoint

    @State private var idInput: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @Dependency(\.homeClient) private var homeClient
    @Dependency(\.sessionClient) private var sessionClient
    @Dependency(\.wordClient) private var wordClient

    var body: some View {
        Form {
            if endpoint.hasIdParam {
                Section("파라미터") {
                    TextField("id", text: $idInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }

            Section {
                Button {
                    Task { await call() }
                } label: {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("호출")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(isLoading || (endpoint.hasIdParam && idInput.isEmpty))
            }

            if let error = errorMessage {
                Section("오류") {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.system(.caption, design: .monospaced))
                }
            }

            if !response.isEmpty {
                Section("응답") {
                    ScrollView {
                        Text(response)
                            .font(.system(.caption2, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 500)
                }
            }
        }
        .navigationTitle(endpoint.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @MainActor
    private func call() async {
        isLoading = true
        errorMessage = nil
        response = ""
        defer { isLoading = false }

        do {
            switch endpoint {
            case .homeOverview:
                let result = try await homeClient.fetchHomeOverview()
                response = dumpString(result)
            case .sessionDetail:
                let result = try await sessionClient.fetchSessionDetail(idInput)
                response = dumpString(result)
            case .wordDetail:
                let result = try await wordClient.fetchWordDetail(idInput)
                response = dumpString(result)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func dumpString<T>(_ value: T) -> String {
        var output = ""
        dump(value, to: &output)
        return output
    }
}
