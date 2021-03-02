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
            .fetchDecodable(fromUrl: validURL)
            .sink(receiveCompletion: { _ in XCTFail() },
                  receiveValue: { model in
                    XCTAssert(model == self.validModel)
            })

        fetcherMock.publish(validModel)
    }

    func test_whenDataFetcherFail_shouldFailWithURLError() {
        sub = sut
            .fetchDecodable(fromUrl: validURL)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                    case .apiError = error {
                    XCTAssert(true)
                } else { XCTFail() }
            }, receiveValue: { (model: TestModel) in  XCTFail() })

        fetcherMock.publish(error: .apiError(URLError(.badURL)))
    }

    func test_whenCannotDecode_shouldFailWithUnableToDecode() {
        sub = sut
            .fetchDecodable(fromUrl: validURL)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                    case .unableToDecode = error {
                    XCTAssert(true)
                } else { XCTFail() }
            }, receiveValue: { (model: TestModel) in XCTFail() })
        let dismatchedModel = 34
        fetcherMock.publish(dismatchedModel)
    }

    func test_whenPassingValidEndPoint_shouldPublishAndDecodeValidData() {
        sub = sut
            .fetchDecodable(fromEndpoint: TestEndpoint.success)
            .sink(receiveCompletion: { _ in XCTFail() },
                  receiveValue: { model in
                    XCTAssert(model == self.validModel)
            })

        fetcherMock.publish(validModel)
    }

    func test_whenPassingInvalidEndPoint_shouldFailWithMalformedURL() {
        sub = sut
            .fetchDecodable(fromEndpoint: TestEndpoint.failure)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion,
                    case .malformedURL = error {
                    XCTAssert(true)
                } else { XCTFail() }
            }, receiveValue: { (model: TestModel) in  XCTFail() })

        fetcherMock.publish(validModel)
    }
}
