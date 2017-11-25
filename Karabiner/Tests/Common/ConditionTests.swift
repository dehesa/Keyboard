import XCTest
@testable import Karabiner

class ConditionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecoders() {
        typealias Condition = Karabiner.Manipulator.Condition
        let data = self.data(fileName: "example_device")!

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let decoder = JSONDecoder()
        
        // Original file
        let originalJSON = try? decoder.decode([String:JSON.UnknownValue].self, from: data)
        let originalData = try? encoder.encode(originalJSON!)
        let original = String(bytes: originalData!, encoding: .utf8)!
        print("\n\n\(original)\n\n")
        
        
        let parsedJSON = try? decoder.decode(Karabiner.File.self, from: data)
        let parsedData = try? encoder.encode(parsedJSON!)
        let parsed = String(bytes: parsedData!, encoding: .utf8)!
        print("\n\n\(parsed)\n\n")
    }
    
    private func data(fileName: String, fileExtension: String = "json") -> Data? {
        guard let url = Bundle(for: ConditionTests.self).url(forResource: fileName, withExtension: fileExtension) else { return nil }
        return try? Data(contentsOf: url)
    }
}
