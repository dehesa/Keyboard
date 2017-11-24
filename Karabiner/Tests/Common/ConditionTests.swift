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
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let apps = Condition.apps(.is, bundles: ["regex 1", "regex 2"], paths: ["fileA", "fileB"], title: "Manolo")!
        let data = try! encoder.encode(apps)
        print("\n\n\(String(bytes: data, encoding: .utf8)!)\n\n")
        
        let decoder = JSONDecoder()
        let returned = try! decoder.decode(Condition.self, from: data)
        print("\n\n\(returned)\n\n")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
