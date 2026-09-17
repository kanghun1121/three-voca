import SwiftUI

/// 단계명 + 설명 2줄 라벨. `StageRow`에서만 쓰는 화면 전용 서브뷰.
struct StageNameLabel: View {
    let name: String
    let description: String
    let textColor: Color
    let secondaryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .stageTypography(.stageName)
                .foregroundStyle(textColor)
            Text(description)
                .stageTypography(.stageDescription)
                .foregroundStyle(secondaryColor)
        }
    }
}
