import XCTest
@testable import Karabiner

class MarcosTests: XCTestCase {
    /// Modes names
    let mode: (left: String, right: String, shift: String) = ("mode_left", "mode_right", "mode_shift")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMarcos() {
        let rules = [rulesLeft(), rulesRight(), rulesShift()].flatMap { $0 }
        let file = File("Marcos basics", rules: rules)

        let desktop = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
        let url = desktop.appendingPathComponent("Marcos").appendingPathExtension("json")
        
        let data = try! JSONEncoder().encode(file)
        try! data.write(to: url)
    }
    
    private func rulesLeft() -> [Rule] {
        /// Rule that triggers the left mode.
        let basic = Rule("Left mode", manipulators: [
            Manipulator("Caps -> \(mode.left)", input: Input(keyCode: .caps, optional: .any), outputs: Triggers(press: [Output(variable: mode.left, value: 1)], release: [Output(variable: mode.left, value: 0)]) )
        ])
        
        /// Condition that checks whether the left mode is active.
        let isLeft = Condition(.are, variableName: mode.left, value: 1, "Check for Development Mode")
        
        /// Handle the arrow keys.
        let arrows = { (pairs) -> Rule in
            Rule("Left mode (arrows)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.left)+\(i.rawValue.uppercased) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(Keyboard.Key.j,Keyboard.Key.left), (.i,.up), (.k,.down), (.l,.right)] )
        
        /// Handle Delete and Enter
        let delete = Rule("Left mode (delete, enter, escape)", manipulators: [
            Manipulator("\(mode.left)+Space", input: Input(keyCode: .space,     optional: .any), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: .enter)])),
            Manipulator("\(mode.left)+U",     input: Input(keyCode: .u,         optional: .any), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: .deleteBack)])),
            Manipulator("\(mode.left)+O",     input: Input(keyCode: .o,         optional: .any), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: .deleteForward)])),
            Manipulator("\(mode.left)+ESC",   input: Input(keyCode: .semicolon, optional: .any), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: .escape)]))
        ])
        
        /// Tab switching
        let tabSwitching = Rule("Left mode (tab switching)", manipulators: [
            Manipulator("\(mode.left)+Tab", input: Input(keyCode: .tab, optional: .modifiers([.shift, .option, .command, .fn])), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control])]))
        ])
        
        /// Numbers for Function keys
        let fnKeys = { (pairs) -> Rule in
            Rule("Left mode (F#)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.left)+\(i.rawValue) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: [isLeft], outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(Keyboard.Key.one,Keyboard.Key.f1), (.two,.f2), (.three,.f3), (.four,.f4), (.five,.f5), (.six,.f6), (.seven,.f7), (.eight,.f8), (.nine,.f9), (.zero,.f10), (.hyphen,.f11), (.equal,.f12), (.deleteBack,.f13)] )
        
        return [basic, arrows, delete, tabSwitching, fnKeys]
    }
    
    private func rulesRight() -> [Rule] {
        /// Rule that triggers the right mode.
        let basic = Rule("Right mode", manipulators: [
            Manipulator("Quote -> \(mode.right)", input: Input(keyCode: .quote, optional: .any), outputs: Triggers(press: [Output(variable: mode.right, value: 1)], pressAlone: [Output(keyCode: .quote)], release: [Output(variable: mode.right, value: 0)]) )
        ])
        
        /// Condition that checks whether the right mode is active.
        let isRight = Condition(.are, variableName: mode.right, value: 1, "Check for Development Mode")
        
        let keyPad = { (pairs) -> Rule in
            Rule("Right mode (keypad)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.right)+\(i.rawValue.uppercased) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: [isRight], outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(Keyboard.Key.tab,Keyboard.Key.pad0), (.z,.pad1), (.x,.pad2), (.c,.pad3), (.a,.pad4), (.s,.pad5), (.d,.pad6), (.q,.pad7), (.w,.pad8), (.e,.pad9), (.f,.padPeriod), (.g,.padSlash), (.r,.padPlus), (.v,.padHyphen), (.t,.padAsterisk), (.b,.padEqual)] )
        
        return [basic, keyPad]
    }
    
    private func rulesShift() -> [Rule] {
        let basic = Rule("Shift mode", manipulators: [
            Manipulator("Left Shift -> (",   input: Input(keyCode: .shiftL, mandatory: .none, optional: .none), outputs: Triggers(press: [Output(keyCode: .shiftL)], pressAlone: [Output(keyCode: .eight, modifiers: [.shift])])),
            Manipulator("Right Shift -> )",  input: Input(keyCode: .shiftR, mandatory: .none, optional: .none), outputs: Triggers(press: [Output(keyCode: .shiftR)], pressAlone: [Output(keyCode: .nine,  modifiers: [.shift])])),
            Manipulator("R+L Shift -> Caps", input: Input(keyCode: .shiftL, mandatory: .modifiers([.shiftR]), optional: .modifiers([.caps])), outputs: Triggers(press: [Output(keyCode: .caps)])),
            Manipulator("L+R Shift -> Caps", input: Input(keyCode: .shiftR, mandatory: .modifiers([.shiftL]), optional: .modifiers([.caps])), outputs: Triggers(press: [Output(keyCode: .caps)]))
        ])
        
        return [basic]
    }
}
