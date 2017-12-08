import XCTest
@testable import Karabiner

class JSONTests: XCTestCase {
    /// Tests downloaded JSON rules to check the library identifies all clearly.
    func testExample() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let decoder = JSONDecoder()
        
        let (data, files) = self.setupFiles(name: "vi_style_arrows")
        
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

    /// Download the testing file and gives the URL for the file to be created.
    private func setupFiles(name: String) -> (data: Data, url: (original: URL, modified: URL)) {
        // Retrieves the third party JSON from the bundle.
        guard let bundleFileURL = Bundle(for: JSONTests.self).url(forResource: name, withExtension: "json") else { fatalError("JSON file \"\(name).json\" for testing not found!") }
        guard let data = try? Data(contentsOf: bundleFileURL) else { fatalError("JSON file \"\(name).json\" couldn't be parsed into data.") }
        
        /// Set up the URL for the original and modified file.
        let home = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
        let original = home.appendingPathComponent("original").appendingPathExtension("json")
        let modified = home.appendingPathComponent("modified").appendingPathExtension("json")
        
        return (data, (original, modified))
    }

}
