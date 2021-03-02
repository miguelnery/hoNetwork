import Foundation


enum NetworkError: Error, Equatable {
    case url(URLError)
    case unableToDecode
}
