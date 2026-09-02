import XCTest

import DomainInterface

final class PartOfSpeechTests: XCTestCase {
    func test_알려진_rawValue_9종은_각각의_case로_디코딩된다() {
        XCTAssertEqual(PartOfSpeech(rawValue: "noun"), .noun)
        XCTAssertEqual(PartOfSpeech(rawValue: "verb"), .verb)
        XCTAssertEqual(PartOfSpeech(rawValue: "adjective"), .adjective)
        XCTAssertEqual(PartOfSpeech(rawValue: "adverb"), .adverb)
        XCTAssertEqual(PartOfSpeech(rawValue: "preposition"), .preposition)
        XCTAssertEqual(PartOfSpeech(rawValue: "conjunction"), .conjunction)
        XCTAssertEqual(PartOfSpeech(rawValue: "interjection"), .interjection)
        XCTAssertEqual(PartOfSpeech(rawValue: "pronoun"), .pronoun)
        XCTAssertEqual(PartOfSpeech(rawValue: "unknown"), .unknown)
    }

    func test_알수없는_rawValue는_nil을_반환한다() {
        XCTAssertNil(PartOfSpeech(rawValue: "determiner"))
        XCTAssertNil(PartOfSpeech(rawValue: ""))
    }
}
