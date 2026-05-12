import SwiftUI

struct RootView: View {
    @State private var output = "Tap fetch to start"
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(output)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding()
            }
            ActionButtons(
                isLoading: isLoading,
                onFetchLevels: {
                    fetch(url: URL(string: "https://ebvfeuopuzlpddzvcini.supabase.co/rest/v1/rpc/get_all_levels_with_sessions")!)
                },
                onFetchDetail: {
                    fetch(url: URL(string: "https://ebvfeuopuzlpddzvcini.supabase.co/rest/v1/rpc/get_session_detail?p_session_id=1")!)
                }
            )
        }
    }

    private func fetch(url: URL) {
        isLoading = true
        Task {
            output = await loadJSON(url: url)
            isLoading = false
        }
    }

    private func loadJSON(url: URL) async -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return prettify(data)
        } catch {
            return "Error: \(error)"
        }
    }

    private func prettify(_ data: Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            ),
            let string = String(data: pretty, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "(non-UTF8 response)"
        }
        return string
    }
}

private struct ActionButtons: View {
    let isLoading: Bool
    let onFetchLevels: () -> Void
    let onFetchDetail: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button("Fetch levels", action: onFetchLevels)
                .disabled(isLoading)
                .buttonStyle(.borderedProminent)
            Button("Fetch session detail", action: onFetchDetail)
                .disabled(isLoading)
                .buttonStyle(.borderedProminent)
        }
        .padding(.bottom)
    }
}

private enum SupabaseConfig {
    static let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
}
