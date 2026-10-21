import Foundation

import DomainInterface

extension LessonRepository {
    /// 표시·입력 경계가 되는 단어 4개로 구성한 레슨: 굉장히 짧은 단어, 띄어쓰기가 있는 단어,
    /// 대문자가 섞인 단어, 굉장히 긴 단어.
    static let happyPath = LessonRepository(
        fetchDetail: { id in
            Lesson(
                id: id,
                level: 1,
                lessonNumber: 1,
                cefrLevel: "A1",
                words: [
                    Lesson.Word(
                        id: "w1",
                        term: "a",
                        pronunciation: "/eɪ/",
                        definitions: [.init(id: "d1", partOfSpeech: .unknown, meaning: "하나의")],
                        distractors: ["그", "이", "어떤"],
                        audioUrl: ""
                    ),
                    Lesson.Word(
                        id: "w2",
                        term: "ice cream",
                        pronunciation: "/aɪs kriːm/",
                        definitions: [.init(id: "d2", partOfSpeech: .noun, meaning: "아이스크림")],
                        distractors: ["샌드위치", "초콜릿", "케이크"],
                        audioUrl: ""
                    ),
                    Lesson.Word(
                        id: "w3",
                        term: "iPhone",
                        pronunciation: "/ˈaɪ.foʊn/",
                        definitions: [.init(id: "d3", partOfSpeech: .noun, meaning: "아이폰")],
                        distractors: ["노트북", "태블릿", "시계"],
                        audioUrl: ""
                    ),
                    Lesson.Word(
                        id: "w4",
                        term: "electroencephalography",
                        pronunciation: "/ɪˌlektroʊenˌsefəˈlɒɡrəfi/",
                        definitions: [.init(id: "d4", partOfSpeech: .noun, meaning: "뇌파 검사")],
                        distractors: ["혈액 검사", "시력 검사", "심전도 검사"],
                        audioUrl: ""
                    ),
                ]
            )
        }
    )
}
