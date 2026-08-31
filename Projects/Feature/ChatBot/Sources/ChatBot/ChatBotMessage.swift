import Foundation

/// 대화 히스토리 한 줄. 사용자 질문과 AI 응답이 순서대로 쌓인다.
struct ChatBotMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    var text: String
    /// AI 응답 자리표시 상태 — 첫 청크가 도착하기 전까지 true. 이 동안은 텍스트 대신
    /// 스피너 + 대기 문구를 렌더한다.
    var isGenerating: Bool = false
}
