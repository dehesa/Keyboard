import Cocoa
import Karabiner

var encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let decoder = JSONDecoder()

//let input = Keyboard.Input(.key(.e), [.shift, .shiftL, .control, .command], optional: [.caps, .fn])
let input = Keyboard.Input(.key(.e), .modifiers([.shift, .shiftL, .controlR, .command]), optional: .none)

let data = try! encoder.encode(input)
print(String(bytes: data, encoding: .utf8)!)

let decoded = try decoder.decode(Keyboard.Input.self, from: data)
decoded.mandatory
decoded.optional
