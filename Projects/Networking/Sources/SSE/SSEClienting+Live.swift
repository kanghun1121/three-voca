import Foundation

import NetworkingInterface

import Dependencies

extension SSEClientKey: DependencyKey {
    public static let liveValue: any SSEClienting = SSEClient()
}
