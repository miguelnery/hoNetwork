import Foundation
import Combine
@testable import hoNetwork

class DataFetcherMock: DataFectherType {
    private let subject = PassthroughSubject<Data, NetworkError>()

    func publish<T: Encodable>(_ model: T) {
        guard let data = try? JSONEncoder().encode(model) else {
            fatalError("Unable to encode model")
        }
        subject.send(data)
    }

    func publish(error: NetworkError) {
        subject.send(completion: .failure(error))
    }

    func fetchData(from url: URL) -> AnyPublisher<Data, NetworkError> {
        return subject
            .eraseToAnyPublisher()
    }
}
