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
    
    func testDevices() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let decoder = JSONDecoder()
        
        let (data, files) = ConditionTests.setup(fileName: "vi_style_arrows")
        
        // Original file
        do {
            let originalJSON = try decoder.decode([String:JSON.UnknownValue].self, from: data)
            let originalData = try encoder.encode(originalJSON)
            try originalData.write(to: files.original)
        
        // Parsed file
            let parsedJSON = try decoder.decode(Karabiner.File.self, from: data)
            let parsedData = try encoder.encode(parsedJSON)
            try parsedData.write(to: files.modified)
        } catch let error {
            print("\n\n\(error)\n\n")
        }
    }
    
    internal static func setup(fileName: String) -> (data: Data, url: (original: URL, modified: URL)) {
        guard let bundleFileURL = Bundle(for: ConditionTests.self).url(forResource: fileName, withExtension: "json") else { fatalError("JSON file \"\(fileName).json\" for testing not found!") }
        guard let data = try? Data(contentsOf: bundleFileURL) else { fatalError("JSON file \"\(fileName).json\" couldn't be parsed into data.") }
        
        let home = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
        let original = home.appendingPathComponent("original").appendingPathExtension("json")
        let modified = home.appendingPathComponent("modified").appendingPathExtension("json")
        
        return (data, (original, modified))
    }
}
