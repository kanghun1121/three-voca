import SwiftUI

import DesignSystem
import DomainInterface

struct StageHeroSection: View {
    let level: LevelSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            StageKeylineBar(color: StageColor.resolveLight(forLevel: level.level), width: 32, height: 6)
            Text("STEP \(level.level, format: .number.precision(.integerLength(2)))")
                .stageTypography(.stepLabel)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            Text(level.name)
                .stageTypography(.detailStageName)
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text(metaText)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            StageProgressTrack(ratio: level.progressRatio, fillColor: StageColor.resolveLight(forLevel: level.level), height: 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private var metaText: String {
        let totalWords = level.lessons.reduce(0) { $0 + $1.totalWords }
        return "\(totalWords)개 단어 · \(level.totalLessons)개 세션 · \(level.completedLessons)개 완료"
    }
}
