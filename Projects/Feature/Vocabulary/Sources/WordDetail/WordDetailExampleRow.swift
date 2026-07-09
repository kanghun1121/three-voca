import NaturalLanguage
import SwiftUI

import DesignSystem

struct WordDetailExampleRow: View {
    let term: String
    let example: WordDetailPresentationModel.ExampleRow
    let onChunkReaderTapped: (WordDetailPresentationModel.ExampleRow) -> Void
    // NLTagger 파이프라인은 view 생성/body 평가를 막지 않도록 task()에서 채운다
    @State private var highlightedEnText: Text? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            (highlightedEnText ?? Text(example.en))
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)

            Text(example.ko)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

            if let chunks = example.chunks, !chunks.isEmpty {
                Button {
                    onChunkReaderTapped(example)
                } label: {
                    Label {
                        Text("끊어읽기")
                            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                    } icon: {
                        Image(systemName: "text.word.spacing")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
                }
                .padding(.vertical, 8)
                .contentShape(.rect)
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemAsset.study100.swiftUIColor.opacity(0.5))
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(DesignSystemAsset.study100.swiftUIColor, lineWidth: 1)
        }
        .task(id: "\(term)|\(example.en)") {
            highlightedEnText = Self.buildHighlightedText(sentence: example.en, keyword: term)
        }
    }

    // TODO: - NLTagger 파이프라인(computeLemma/findTokenRanges/findPhraseRanges)이 View에 혼재함. 별도 타입으로 분리 필요
    private static func buildHighlightedText(sentence: String, keyword: String) -> Text {
        let matchRanges = keyword.contains(" ")
            ? findPhraseRanges(in: sentence, phrase: keyword)
            : findTokenRanges(in: sentence, keyword: keyword)

        guard !matchRanges.isEmpty else {
            return Text(sentence)
        }

        var attributed = AttributedString(sentence)
        let boldFont = DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16)

        for strRange in matchRanges {
            let startOffset = sentence.distance(from: sentence.startIndex, to: strRange.lowerBound)
            let endOffset = sentence.distance(from: sentence.startIndex, to: strRange.upperBound)
            let attrStart = attributed.index(attributed.startIndex, offsetByCharacters: startOffset)
            let attrEnd = attributed.index(attributed.startIndex, offsetByCharacters: endOffset)
            attributed[attrStart..<attrEnd].swiftUI.foregroundColor = DesignSystemAsset.study300.swiftUIColor
            attributed[attrStart..<attrEnd].swiftUI.backgroundColor = DesignSystemAsset.highlightBg.swiftUIColor
            attributed[attrStart..<attrEnd].swiftUI.font = boldFont
        }

        return Text(attributed)
    }

    private static func computeLemma(of word: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = word
        var result = word.lowercased()
        tagger.enumerateTags(
            in: word.startIndex..<word.endIndex,
            unit: .word,
            scheme: .lemma
        ) { tag, _ in
            if let tag {
                result = tag.rawValue.lowercased()
            }
            return false
        }
        return result
    }

    // 키워드를 문맥 없이 고립시켜 렘마화하면(computeLemma(of:)) 문장 속 문맥 기반 렘마와 품사 추정이 어긋나
    // 같은 단어인데도 다른 렘마가 나올 수 있다 (예: 고립된 "shopping" → "shop", 문장 속 "shopping" → "shopping").
    // 표층형이 그대로 일치하는 절대다수의 경우를 렘마 비교보다 먼저 확인해 이 불일치를 우회한다.
    private static func findTokenRanges(in sentence: String, keyword: String) -> [Range<String.Index>] {
        let keywordLower = keyword.lowercased()
        let keywordLemma = computeLemma(of: keyword)
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = sentence
        var ranges: [Range<String.Index>] = []
        tagger.enumerateTags(
            in: sentence.startIndex..<sentence.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, tokenRange in
            let tokenText = sentence[tokenRange].lowercased()
            let tokenLemma = tag?.rawValue.lowercased() ?? tokenText
            if tokenText == keywordLower || tokenLemma == keywordLemma {
                ranges.append(tokenRange)
            }
            return true
        }
        return ranges
    }

    // "have to", "used to" 같은 구(phrase) 키워드를 연속 토큰 시퀀스로 매칭
    private static func findPhraseRanges(in sentence: String, phrase: String) -> [Range<String.Index>] {
        let literalMatches = findLiteralPhraseRanges(in: sentence, phrase: phrase)
        guard literalMatches.isEmpty else { return literalMatches }

        let phraseLemmas = computeLemmas(of: phrase)
        guard !phraseLemmas.isEmpty else { return [] }

        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = sentence

        var tokens: [(lemma: String, range: Range<String.Index>)] = []
        tagger.enumerateTags(
            in: sentence.startIndex..<sentence.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, tokenRange in
            let tokenLemma = tag?.rawValue.lowercased() ?? String(sentence[tokenRange]).lowercased()
            tokens.append((tokenLemma, tokenRange))
            return true
        }

        var ranges: [Range<String.Index>] = []
        let phraseCount = phraseLemmas.count
        guard tokens.count >= phraseCount else { return [] }
        for i in 0...(tokens.count - phraseCount) {
            let slice = tokens[i..<(i + phraseCount)]
            guard let start = slice.first?.range.lowerBound, let end = slice.last?.range.upperBound else { continue }
            if zip(slice, phraseLemmas).allSatisfy({ $0.lemma == $1 }) {
                ranges.append(start..<end)
            }
        }
        return ranges
    }

    // phrase 표층형이 대소문자만 다르게 문장에 그대로 등장하는 모든 위치를 찾는다.
    // 단어 경계를 넘나드는 오탐(예: "to go"가 "photo goes"의 "oto go" 부분과 매칭)을 막기 위해
    // 매칭 앞뒤가 단어 문자(alphanumeric)가 아닌 경우에만 채택한다.
    private static func findLiteralPhraseRanges(in sentence: String, phrase: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStart = sentence.startIndex
        while let found = sentence.range(
            of: phrase,
            options: .caseInsensitive,
            range: searchStart..<sentence.endIndex
        ) {
            searchStart = found.upperBound
            let hasLeadingBoundary = found.lowerBound == sentence.startIndex
                || !sentence[sentence.index(before: found.lowerBound)].isLetter
            let hasTrailingBoundary = found.upperBound == sentence.endIndex
                || !sentence[found.upperBound].isLetter
            if hasLeadingBoundary, hasTrailingBoundary {
                ranges.append(found)
            }
        }
        return ranges
    }

    private static func computeLemmas(of phrase: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = phrase
        var result: [String] = []
        tagger.enumerateTags(
            in: phrase.startIndex..<phrase.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, tokenRange in
            let tokenLemma = tag?.rawValue.lowercased() ?? String(phrase[tokenRange]).lowercased()
            result.append(tokenLemma)
            return true
        }
        return result
    }
}
