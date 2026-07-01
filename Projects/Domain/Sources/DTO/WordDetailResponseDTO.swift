import Foundation

struct WordDetailResponseDTO: Decodable {
    struct DefinitionDTO: Decodable {
        let meaning: String
        let partOfSpeech: String
    }

    struct ExampleDTO: Decodable {
        struct WordDTO: Decodable {
            let word: String
            let meaning: String
            let pos: String
        }

        struct ChunkDTO: Decodable {
            let text: String
            let meaning: String
        }

        let en: String
        let ko: String
        let order: Int
        let words: [WordDTO]?
        let chunks: [ChunkDTO]?

        private enum CodingKeys: String, CodingKey {
            case en, ko, order, words, chunks
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            en = try container.decode(String.self, forKey: .en)
            ko = try container.decode(String.self, forKey: .ko)
            order = try container.decode(Int.self, forKey: .order)
            words = Self.decodeFlexibleArray(container: container, key: .words)
            chunks = Self.decodeFlexibleArray(container: container, key: .chunks)
        }

        // 백엔드 응답이 레코드에 따라 JSON 문자열로 인코딩되어 오거나(예: 사용자가 준 샘플 데이터),
        // 네이티브 JSON 배열로 오는 경우가 혼재해 있어(디코딩 실패: "Expected to decode String but found
        // an array instead") 두 형태 모두 안전하게 처리한다.
        private static func decodeFlexibleArray<T: Decodable>(
            container: KeyedDecodingContainer<CodingKeys>,
            key: CodingKeys
        ) -> [T]? {
            if let array = try? container.decodeIfPresent([T].self, forKey: key) {
                return array
            }
            if let jsonString = try? container.decodeIfPresent(String.self, forKey: key),
               let data = jsonString.data(using: .utf8) {
                return try? JSONDecoder().decode([T].self, from: data)
            }
            return nil
        }
    }

    let id: String
    let term: String
    let level: Int
    let pronunciation: String
    let definitions: [DefinitionDTO]
    let examples: [ExampleDTO]
}
