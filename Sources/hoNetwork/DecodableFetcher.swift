import Foundation
import Combine

protocol DecodableFectherType {
    func fetchDecodable<T: Decodable>(from url: URL, decoder: JSONDecoder) -> AnyPublisher<T, NetworkError>
}

class DecodableFecther {
    private let dataFetcher: DataFectherType

    init(dataFetcher: DataFectherType = DataFetcher()) { self.dataFetcher = dataFetcher }
}

extension DecodableFecther: DecodableFectherType {
    func fetchDecodable<T: Decodable>(from url: URL, decoder: JSONDecoder = .init()) -> AnyPublisher<T, NetworkError> {
        dataFetcher
            .fetchData(from: url)
            .decode(type: T.self, decoder: decoder, errorTransform: { _ in .unableToDecode })
            .eraseToAnyPublisher()
    }
}
