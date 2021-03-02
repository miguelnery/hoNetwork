import Foundation
import Combine

public protocol DecodableFectherType {
    func fetchDecodable<T: Decodable>(fromUrl url: URL, decoder: JSONDecoder) -> AnyPublisher<T, NetworkError>
    func fetchDecodable<T: Decodable, E: Endpoint>(fromEndpoint endpoint: E, decoder: JSONDecoder) -> AnyPublisher<T, NetworkError>
    
}

public class DecodableFecther {
    private let dataFetcher: DataFectherType

    public init(dataFetcher: DataFectherType = DataFetcher()) { self.dataFetcher = dataFetcher }
}

extension DecodableFecther: DecodableFectherType {
    public func fetchDecodable<T: Decodable>(fromUrl url: URL,
                                             decoder: JSONDecoder = .init()) -> AnyPublisher<T, NetworkError> {
        dataFetcher
            .fetchData(fromUrl: url)
            .decode(type: T.self, decoder: decoder, errorTransform: { _ in .unableToDecode })
            .eraseToAnyPublisher()
    }

    public func fetchDecodable<T: Decodable, E: Endpoint>(fromEndpoint endpoint: E,
                                             decoder: JSONDecoder = .init()) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.url else {
            return Fail<T, NetworkError>(error: .malformedURL)
                .eraseToAnyPublisher()
        }
        return fetchDecodable(fromUrl: url)
    }
}
