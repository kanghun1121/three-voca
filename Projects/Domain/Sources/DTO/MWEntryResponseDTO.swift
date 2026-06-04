import Foundation

struct MWEntryResponseDTO: Decodable {
    struct HWI: Decodable {
        struct Pronunciation: Decodable {
            struct Sound: Decodable {
                let audio: String?
            }
            let sound: Sound?
        }
        let prs: [Pronunciation]?
    }
    let hwi: HWI?
}
