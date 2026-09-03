import Foundation

import NetworkingInterface

import Dependencies

extension AuthenticatedHTTPClientKey: DependencyKey {
    public static let liveValue: any HTTPClienting = HTTPClient(interceptor: TokenRefreshInterceptor())
}
