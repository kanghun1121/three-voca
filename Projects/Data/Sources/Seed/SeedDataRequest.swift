import Foundation

import NetworkingInterface

/// 시드 데이터는 공개 콘텐츠라 사용자 JWT 없이 anon key만으로 호출한다.
struct SeedDataRequest: Requestable {
    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "rest/v1/rpc/get_seed_data" }
    var method: HTTPMethod { .post }
    var bodyParameters: HTTPBody { .json([String: String]()) }
    var headers: [String: String] { ["apikey": SupabaseConfig.anonKey] }
    var requiresAuthentication: Bool { false }
}
