import NaturalLanguage
import SwiftUI

import DesignSystem

struct WordDetailExampleRow: View {
    let term: String
    let example: WordDetailPresentationModel.ExampleRow
    // body 평가와 독립적으로 init 시점에 한 번만 NLTagger를 실행
    private let highlightedEnText: Text

    init(term: String, example: WordDetailPresentationModel.ExampleRow) {
        self.term = term
        self.example = example
        self.highlightedEnText = Self.buildHighlightedText(sentence: example.en, keyword: term)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            highlightedEnText
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)

            Text(example.ko)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

            Button(action: {}) {
                GrammarAnalysisLabel()
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemAsset.bgSubtle.swiftUIColor)
        .clipShape(.rect(cornerRadius: 12))
    }

    // TODO: - NLTagger 파이프라인(lemma/tokenRanges/phraseRanges)이 View에 혼재함. 별도 타입으로 분리 필요
    private static func buildHighlightedText(sentence: String, keyword: String) -> Text {
        let matchRanges = keyword.contains(" ")
            ? phraseRanges(in: sentence, phrase: keyword)
            : tokenRanges(in: sentence, matchingLemma: lemma(of: keyword))

        guard !matchRanges.isEmpty else {
            return Text(sentence)
        }

        var result = Text("")
        var cursor = sentence.startIndex

        for range in matchRanges {
            let before = String(sentence[cursor..<range.lowerBound])
            let match = String(sentence[range])
            // SwiftUI Text는 background를 Text 연결에서 지원하지 않으므로
            // bold + cautionary 색상으로 키워드를 강조 표시
            result = result + Text(before) + Text(match)
                .bold()
                .foregroundStyle(DesignSystemAsset.cautionary.swiftUIColor)
            cursor = range.upperBound
        }

        result = result + Text(String(sentence[cursor...]))
        return result
    }

    private static func lemma(of word: String) -> String {
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

    private static func tokenRanges(in sentence: String, matchingLemma keywordLemma: String) -> [Range<String.Index>] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = sentence
        var ranges: [Range<String.Index>] = []
        tagger.enumerateTags(
            in: sentence.startIndex..<sentence.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, tokenRange in
            let tokenLemma = tag?.rawValue.lowercased() ?? String(sentence[tokenRange]).lowercased()
            if tokenLemma == keywordLemma {
                ranges.append(tokenRange)
            }
            return true
        }
        return ranges
    }

    // "have to", "used to" 같은 구(phrase) 키워드를 연속 토큰 시퀀스로 매칭
    private static func phraseRanges(in sentence: String, phrase: String) -> [Range<String.Index>] {
        let phraseLemmas = lemmas(of: phrase)
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
        for i in 0...(tokens.count - phraseCount) where tokens.count >= phraseCount {
            let slice = tokens[i..<(i + phraseCount)]
            if zip(slice, phraseLemmas).allSatisfy({ $0.lemma == $1 }) {
                let start = slice.first!.range.lowerBound
                let end = slice.last!.range.upperBound
                ranges.append(start..<end)
            }
        }
        return ranges
    }

    private static func lemmas(of phrase: String) -> [String] {
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
