import XCTest
@testable import Karabiner

class InputTests: XCTestCase {

//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }

//    func testInputKey() {
//        let key = Input.Key(.a, Input.Modifiers(.only([.optionR]), optional: .any))
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let data = try! encoder.encode(key)
//        let string = String(data: data, encoding: .utf8)!
//        print(string)
//    }
    
    // TODO: Check to put in inputs keycode and mouse button pressed. It should fail. But I am not sure it will.
    
    func testModifiers() {
        let (encoder, decoder) = (JSONEncoder(), JSONDecoder())
        encoder.outputFormatting = .prettyPrinted
        
        do { // 1: No modifier body definition.
            let inputJSON = "{}"
            let inputData = inputJSON.data(using: .utf8)!
            let modifiers = try! decoder.decode(Input.Modifiers.self, from: inputData)
            XCTAssertTrue(modifiers.isEmpty)
            let outputData = try! encoder.encode(modifiers)
            let outputJSON = String(data: outputData, encoding: .utf8)!
            XCTAssertFalse(outputJSON.isEmpty)
            //print(outputJSON)
        }
        
        do { // 2: No mandatory definition and empty optional.
            let inputJSON = "{ \"optional\": [] }"
            let inputData = inputJSON.data(using: .utf8)!
            let modifiers = try! decoder.decode(Input.Modifiers.self, from: inputData)
            XCTAssertTrue(modifiers.isEmpty)
            let outputData = try! encoder.encode(modifiers)
            let outputJSON = String(data: outputData, encoding: .utf8)!
            XCTAssertFalse(outputJSON.isEmpty)
            //print(outputJSON)
        }
        
        do { // 3: Empty mandatory and no optional definition.
            let inputJSON = "{ \"mandatory\": [] }"
            let inputData = inputJSON.data(using: .utf8)!
            let modifiers = try! decoder.decode(Input.Modifiers.self, from: inputData)
            XCTAssertTrue(modifiers.isEmpty)
            let outputData = try! encoder.encode(modifiers)
            let outputJSON = String(data: outputData, encoding: .utf8)!
            XCTAssertFalse(outputJSON.isEmpty)
            //print(outputJSON)
        }
        
        do { // 4: Empty mandatory and empty optional.
            let inputJSON = "{ \"mandatory\": [], \"optional\": [] }"
            let inputData = inputJSON.data(using: .utf8)!
            let modifiers = try! decoder.decode(Input.Modifiers.self, from: inputData)
            XCTAssertTrue(modifiers.isEmpty)
            let outputData = try! encoder.encode(modifiers)
            let outputJSON = String(data: outputData, encoding: .utf8)!
            XCTAssertFalse(outputJSON.isEmpty)
            //print(outputJSON)
        }
    }
}
