import Foundation

import Core

import Dependencies

extension DependencyValues {
    var httpClient: any HTTPClienting {
        get { self[HTTPClientKey.self] }
        set { self[HTTPClientKey.self] = newValue }
    }
}

private enum HTTPClientKey: DependencyKey, TestDependencyKey {
    static let liveValue: any HTTPClienting = HTTPClient()
    static let testValue: any HTTPClienting = unimplemented(
        "\(Self.self).testValue",
        placeholder: HTTPClient()
    )
}
