import Foundation
import Combine

public protocol DataFectherType {
    func fetchData(fromUrl url: URL) -> AnyPublisher<Data, NetworkError>
    func fetchData<E: Endpoint>(fromEndpoint endpoint: E) -> AnyPublisher<Data, NetworkError>
}

public class DataFetcher {
    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) { self.urlSession = urlSession }
}

extension DataFetcher: DataFectherType {
    public func fetchData(fromUrl url: URL) -> AnyPublisher<Data, NetworkError> {
        urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { return NetworkError.apiError($0) }
            .eraseToAnyPublisher()
    }

    public func fetchData<E: Endpoint>(fromEndpoint endpoint: E) -> AnyPublisher<Data, NetworkError> {
        guard let url = endpoint.url else {
            return Fail<Data, NetworkError>(error: .malformedURL)
                .eraseToAnyPublisher()
        }
        return fetchData(fromUrl: url)
    }
}
