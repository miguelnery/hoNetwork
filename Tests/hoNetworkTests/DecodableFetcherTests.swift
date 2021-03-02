import XCTest
import Combine
@testable import hoNetwork

struct TestModel: Codable, Equatable {
    var string: String
    var int: Int
    var double: Double
    static var count = 0

    init() {
        string = String(TestModel.count)
        int = TestModel.count
        double = 1.0 * Double(TestModel.count)
        TestModel.count += 1
    }
}
    
class DecodableFectherTests: XCTestCase {
    let fetcherMock = DataFetcherMock()
    lazy var sut = DecodableFecther(dataFetcher: fetcherMock)
    let validModel = TestModel()
    let validURL = URL(string: "valid")!
    var sub: AnyCancellable?

    func test_onSuccess_shouldPublishAndDecodeValidData() {
        sub = sut
        .fetchDecodable(from: validURL)
        .sink(receiveCompletion: { _ in XCTFail() },
              receiveValue: { model in
                XCTAssert(model == self.validModel)
        })

        fetcherMock.publish(validModel)
    }

    func test_whenDataFetcherFail_shouldFailWithURLError() {
        sub = sut
            .fetchDecodable(from: validURL)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                    case .url = error {
                    XCTAssert(true)
                } else { XCTFail() }
            },
                  receiveValue: { (model: TestModel) in
                    XCTFail()
            })

        fetcherMock.publish(error: .url(URLError(.badURL)))
    }

    func test_whenCannotDecode_shouldFailWithUnableToDecode() {
        sub = sut
            .fetchDecodable(from: validURL)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                    case .unableToDecode = error {
                    XCTAssert(true)
                } else { XCTFail() }
            },
                  receiveValue: { (model: TestModel) in
                    XCTFail()
            })
        let dismatchingModel = 34
        fetcherMock.publish(dismatchingModel)
    }
}


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
