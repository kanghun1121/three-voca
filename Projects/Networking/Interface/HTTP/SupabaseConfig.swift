import Foundation

public enum SupabaseConfig {
    public static let baseURL: URL = {
        let configurationBundle = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") != nil
            ? Bundle.main
            : Bundle.allBundles.first {
                $0.bundleURL.pathExtension == "xctest"
                    && $0.object(forInfoDictionaryKey: "SUPABASE_URL") != nil
            }
        guard let value = configurationBundle?.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: value), url.scheme == "https", url.host != nil else {
            preconditionFailure("SUPABASE_URL must be a valid HTTPS URL")
        }
        return url
    }()
    public static let anonKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
    }()
}
