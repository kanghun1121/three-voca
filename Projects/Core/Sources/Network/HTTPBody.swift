import Foundation

public enum HTTPBody {
    case json(any Encodable)
    case none
}
