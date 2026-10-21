import Foundation

import NetworkingInterface

import Dependencies

extension HTTPClientKey: DependencyKey {
    public static let liveValue: any HTTPClienting = HTTPClient<NoopInterceptor>()
}
