import Foundation

public enum SupabaseConfig {
    public static let baseURL = URL(string: "https://ebvfeuopuzlpddzvcini.supabase.co")!
    public static let anonKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
    }()
}
