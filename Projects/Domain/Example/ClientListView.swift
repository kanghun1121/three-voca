import SwiftUI

struct ClientListView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("GetHomeOverviewUseCase") {
                    NavigationLink("execute()") {
                        EndpointDetailView(endpoint: .homeOverview)
                    }
                }
                Section("SessionClient") {
                    NavigationLink("fetchSessionDetail(id:)") {
                        EndpointDetailView(endpoint: .sessionDetail)
                    }
                }
                Section("WordClient") {
                    NavigationLink("fetchWordDetail(id:)") {
                        EndpointDetailView(endpoint: .wordDetail)
                    }
                }
                Section("AuthClient") {
                    NavigationLink("signInWithApple(identityToken:)") {
                        EndpointDetailView(endpoint: .authSignIn)
                    }
                }
            }
            .navigationTitle("Domain API Explorer")
        }
    }
}
