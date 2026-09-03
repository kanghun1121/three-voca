import SwiftUI

import DesignSystem
import FeatureChatBot

/// 마크다운 문법별 미니 샘플을 원문 스니펫과 함께 나열한다. 문법 하나가 회귀됐는지
/// 응답 전문 하나만으로는 놓치기 쉬운 항목(주의 콜아웃, 4열 표 등)을 개별 확인하기 위함.
struct MarkdownCatalogView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(entries) { entry in
                    MarkdownCatalogEntryView(entry: entry)
                }
            }
            .padding(16)
        }
        .background(DesignSystemAsset.background.swiftUIColor)
    }

    private var entries: [MarkdownCatalogEntry] {
        [
            .init(title: "헤딩", markdown: "## 헤딩 2\n### 헤딩 3\n#### 헤딩 4"),
            .init(title: "인라인 서식", markdown: "**굵게** / *기울임* / `인라인 코드` / ==하이라이트== / [링크](#)"),
            .init(title: "불릿 리스트 (중첩)", markdown: "- 명사\n  - 주소라는 뜻\n- 동사"),
            .init(title: "번호 리스트", markdown: "1. 한정사 뒤 → 명사\n2. 주어 뒤 → 동사"),
            .init(title: "정답·오답 대조", markdown: "- ✓ You love me.\n- ✗ You love I."),
            .init(title: "표 — 2열", markdown: "| 주격 | 목적격 |\n|---|---|\n| I | me |\n| we | us |"),
            .init(title: "표 — 3열 (라벨 고정폭)", markdown: "| 표현 | 쓰이는 상황 |\n|---|---|\n| this form | 지금 보는 서류 |"),
            .init(title: "표 — 4열", markdown: "| 단어 | 품사 | 성분 | 뜻 |\n|---|---|---|---|\n| You | 대명사 | 주어 S | 너는 |"),
            .init(title: "예문 인용", markdown: "> **I love you.**\n> 나는 너를 사랑한다."),
            .init(title: "핵심 콜아웃", markdown: "> [!핵심] 제목\n> 본문 설명"),
            .init(title: "주의 콜아웃", markdown: "> [!주의] 제목\n> 본문 설명"),
            .init(title: "팁 콜아웃", markdown: "> [!팁] 제목\n> 본문 설명"),
            .init(title: "구조 도식", markdown: "```structure\nYou   love   me.\n[S]   [V]    [O]\n```"),
            .init(title: "수평선", markdown: "위 문단\n\n---\n\n아래 문단")
        ]
    }
}

private struct MarkdownCatalogEntry: Identifiable {
    let title: String
    let markdown: String
    var id: String { title }
}

private struct MarkdownCatalogEntryView: View {
    let entry: MarkdownCatalogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.title)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
            MarkdownView(markdown: entry.markdown)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemAsset.bgSubtle.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
