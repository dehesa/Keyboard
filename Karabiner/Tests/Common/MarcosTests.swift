import XCTest
@testable import Karabiner

class MarcosTests: XCTestCase {
    /// Modes names
    let mode: (left: String, right: String, shift: String) = ("mode_left", "mode_right", "mode_shift")

    func testMarcos() {
        let rules = [rulesLeft(), rulesRight(), rulesShift(), rulesMouse()].flatMap { $0 }
        let file = File("Marcos basics", rules: rules)

        let desktop = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/karabiner/assets/complex_modifications")
        let url = desktop.appendingPathComponent("Marcos").appendingPathExtension("json")
        
        let data = try! JSONEncoder().encode(file)
        try! data.write(to: url)
    }
    
    private func rulesLeft() -> [Rule] {
        /// Rule that triggers the left mode.
        let ruleBasic = Rule("Left mode", manipulators: [
            Manipulator("Caps -> \(mode.left)", input: Input(keyCode: .caps, optional: .any), outputs: Triggers(press: [Output(variable: mode.left, value: 1)], release: [Output(variable: mode.left, value: 0)]) )
        ])
        
        /// Condition that checks whether the left mode is active.
        let isLeft   = Condition(.are, variableName: mode.left,  value: 1, "Check that Left Mode is active")
        let notRight = Condition(.are, variableName: mode.right, value: 0, "Check that Right Mode is inactive")
        let modeCondition = [isLeft, notRight]
        
        /// Handle the arrow keys.
        let ruleArrows = { (pairs) -> Rule in
            let directional = pairs.map { (i, o) in
                Manipulator("\(mode.left)+\(i.rawValue.uppercased) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: o)]))
            }
            let leaps = [
                Manipulator("\(mode.left)+U", input: Input(keyCode: .u, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .up), count: 10))),
                Manipulator("\(mode.left)+M", input: Input(keyCode: .m, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .down), count: 10)))
            ]
            
            return Rule("Left mode (arrows)", manipulators: directional+leaps)
        }( [(Keyboard.Key.j,Keyboard.Key.left), (.i,.up), (.k,.down), (.l,.right)] )
        
        /// Handle Delete and Enter
        let ruleDelete = Rule("Left mode (delete, enter, escape)", manipulators: [
            Manipulator("\(mode.left)+Space", input: Input(keyCode: .space,     optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .enter)])),
            Manipulator("\(mode.left)+Ñ",     input: Input(keyCode: .semicolon, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .deleteBack)])),
            Manipulator("\(mode.left)+Slash", input: Input(keyCode: .slash,     optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .deleteForward)])),
            Manipulator("\(mode.left)+H",     input: Input(keyCode: .h,         optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .escape)]))
        ])
        
        /// Tab switching
        let ruleTabs = Rule("Left mode (tab switching)", manipulators: [
            Manipulator("\(mode.left)+Tab", input: Input(keyCode: .tab, optional: .modifiers([.shift, .option, .command, .fn])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control])]))
        ])
        
        /// Numbers for Function keys
        let ruleFn = { (pairs) -> Rule in
            Rule("Left mode (F#)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.left)+\(i.rawValue) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(Keyboard.Key.one,Keyboard.Key.f1), (.two,.f2), (.three,.f3), (.four,.f4), (.five,.f5), (.six,.f6), (.seven,.f7), (.eight,.f8), (.nine,.f9), (.zero,.f10), (.hyphen,.f11), (.equal,.f12), (.deleteBack,.f13)] )
        
        return [ruleBasic, ruleArrows, ruleDelete, ruleTabs, ruleFn]
    }
    
    private func rulesRight() -> [Rule] {
        /// Rule that triggers the right mode.
        let ruleBasic = Rule("Right mode", manipulators: [
            Manipulator("Quote -> \(mode.right)", input: Input(keyCode: .quote, optional: .any), outputs: Triggers(press: [Output(variable: mode.right, value: 1)], pressAlone: [Output(keyCode: .quote)], release: [Output(variable: mode.right, value: 0)]) )
        ])
        
        /// Condition that checks whether the right mode is active.
        let isRight = Condition(.are, variableName: mode.right, value: 1, "Check that Right Mode is active")
        let notLeft = Condition(.are, variableName: mode.left,  value: 0, "Check that Left Mode is inactive")
        let modeCondition = [isRight, notLeft]
        
        let ruleKeyPad = { (pairs) -> Rule in
            Rule("Right mode (keypad)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.right)+\(i.rawValue.uppercased) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(Keyboard.Key.a,Keyboard.Key.pad0), (.s,.pad1), (.d,.pad2), (.f,.pad3), (.g,.pad4),
            (.q,.pad5), (.w,.pad6), (.e,.pad7), (.r,.pad8), (.t,.pad9),
            (.z,.padPeriod), (.accentGrave,.padSlash), (.x,.padPlus), (.c,.padHyphen), (.v,.padAsterisk), (.b,.padEqual)] )
        
        return [ruleBasic, ruleKeyPad]
    }
    
    private func rulesShift() -> [Rule] {
        let ruleBasic = Rule("Shift mode", manipulators: [
            Manipulator("Left Shift -> (",   input: Input(keyCode: .shiftL, mandatory: .none, optional: .none), outputs: Triggers(press: [Output(keyCode: .shiftL)], pressAlone: [Output(keyCode: .eight, modifiers: [.shift])])),
            Manipulator("Right Shift -> )",  input: Input(keyCode: .shiftR, mandatory: .none, optional: .none), outputs: Triggers(press: [Output(keyCode: .shiftR)], pressAlone: [Output(keyCode: .nine,  modifiers: [.shift])])),
            Manipulator("R+L Shift -> Caps", input: Input(keyCode: .shiftL, mandatory: .modifiers([.shiftR]), optional: .modifiers([.caps])), outputs: Triggers(press: [Output(keyCode: .caps)])),
            Manipulator("L+R Shift -> Caps", input: Input(keyCode: .shiftR, mandatory: .modifiers([.shiftL]), optional: .modifiers([.caps])), outputs: Triggers(press: [Output(keyCode: .caps)]))
        ])
        
        return [ruleBasic]
    }
    
    private func rulesMouse() -> [Rule] {
        /// Condition to detect the SwiftPoint mouse.
        let isMouse = Condition(.are, deviceIdentifiers: [(8526, 5, "SwiftPoint mouse")])
        
        /// Rule for managing "tabs" on applications.
        let ruleTabs = Rule("SwiftPoint (tab switching)", manipulators: [
            Manipulator("Button5 -> ⌃+Tab", input: Input(button: .button5), conditions: [isMouse], outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control])])),
            Manipulator("Button4 -> ⌃+⇧+Tab", input: Input(button: .button4), conditions: [isMouse], outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control, .shift])]))
        ])
        
        return [ruleTabs]
    }
}
