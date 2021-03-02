import Foundation


public enum NetworkError: Error, Equatable {
    case apiError(URLError)
    case unableToDecode
    case malformedURL
}
