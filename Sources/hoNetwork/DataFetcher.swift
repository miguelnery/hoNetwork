import Foundation
import Combine

protocol DataFectherType {
    func fetchData(from url: URL) -> AnyPublisher<Data, NetworkError>
}

class DataFetcher {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) { self.urlSession = urlSession }
}

extension DataFetcher: DataFectherType {
    func fetchData(from url: URL) -> AnyPublisher<Data, NetworkError> {
        urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { return NetworkError.url($0) }
            .eraseToAnyPublisher()
    }
}
