import SwiftUI

struct SessionList: View {
    let sessions: [SessionRowPresentationModel]

    var body: some View {
        LazyVStack(spacing: 4) {
            ForEach(sessions) { session in
                SessionRow(presentationModel: session)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .padding(.bottom, 8)
    }
}
