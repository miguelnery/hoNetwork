import Foundation

public protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var url: URL? { get }
}

enum TestEndpoint: Endpoint {
    case failure
    case success

    var path: String { "test" }
    var queryItems: [URLQueryItem] { [] }
    var url: URL? {
        switch self {
        case .failure:
            return nil
        case .success:
            return URL(string: "valid")!
        }
    }
}
