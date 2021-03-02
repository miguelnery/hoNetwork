import XCTest
import Combine
@testable import hoNetwork
    
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
