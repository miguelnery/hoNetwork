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
