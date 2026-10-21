/// 단계(1~6) 인덱스 → 목록 행 설명 문구 매핑 (핸드오프 #123 시안 A). `Domain`/SwiftData에는
/// 이 문구를 담을 필드가 없어(설명 텍스트는 시드 JSON에서도 읽히지 않고 버려짐), 화면 표시
/// 전용 정적 매핑으로 FeatureLesson 안에 둔다. 문구가 없는 단계(오늘은 잠긴 심화·완성)는
/// nil을 반환하고, 호출부(`StageRow`)가 "준비 중"으로 대체한다.
enum StageDescription {
    static func resolveText(forLevel level: Int) -> String? {
        switch level {
        case 1: "가장 기본이 되는 표현"
        case 2: "일상에서 매일 쓰는 말"
        case 3: "문장으로 늘려 쓰기"
        case 4: "주제별로 넓히기"
        default: nil
        }
    }
}
