import Foundation

enum MerriamWebsterConfig {
    static let baseURL = URL(staticString: "https://www.dictionaryapi.com")
    static let apiKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "MW_DICTIONARY_API_KEY") as? String ?? ""
    }()
}
