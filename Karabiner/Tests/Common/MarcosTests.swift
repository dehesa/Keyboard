import XCTest
@testable import Karabiner

class MarcosTests: XCTestCase {
    /// Modes names
    let mode: (left: String, right: String, shift: String) = ("mode_left", "mode_right", "mode_shift")

    func testMarcos() {
        let rules = [rulesLeft(), rulesRight(), rulesBoth(), rulesShift(), rulesMouse()].flatMap { $0 }
        let file = File("Marcos basics", rules: rules)

        let desktop = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/karabiner/assets/complex_modifications")
        let url = desktop.appendingPathComponent("Marcos").appendingPathExtension("json")
        
        let data = try! JSONEncoder().encode(file)
        try! data.write(to: url)
    }
    
    /// Rules that are triggered once the "Left" mode is active (a.k.a. The "Caps" key is pressed).
    /// - returns The rule identifying the "Left" mode and all other rules associated exclusively with it.
    private func rulesLeft() -> [Rule] {
        /// Rule that triggers the left mode.
        let ruleBasic = Rule("Left mode", manipulators: [
            Manipulator("Caps -> \(mode.left)", input: Input(keyCode: .caps, optional: .any), outputs: Triggers(press: [Output(variable: mode.left, value: 1)], release: [Output(variable: mode.left, value: 0)]) )
        ])
        
        /// Condition that checks whether the left mode is active.
        let modeCondition = [ Condition(.are, variableName: mode.left,  value: 1, "Check that Left Mode is active"),
                              Condition(.are, variableName: mode.right, value: 0, "Check that Right Mode is inactive") ]
        
        /// Handle the arrow keys.
        let ruleArrows = Rule("Left mode (arrows)", manipulators: [
            Manipulator("\(mode.left)+J -> ←", input: Input(keyCode: .j, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .left)])),
            Manipulator("\(mode.left)+I -> ↑", input: Input(keyCode: .i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .up)])),
            Manipulator("\(mode.left)+K -> ↓", input: Input(keyCode: .k, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .down)])),
            Manipulator("\(mode.left)+L -> →", input: Input(keyCode: .l, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .right)]))
        ])
        
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
        let modeCondition = [ Condition(.are, variableName: mode.right, value: 1, "Check that Right Mode is active"),
                              Condition(.are, variableName: mode.left,  value: 0, "Check that Left Mode is inactive") ]
        
        /// Rule providing all keypad numbers and symbols on
        let ruleKeyPad = { (pairs: [(Keyboard.Key,Keyboard.Key)]) -> Rule in
            Rule("Right mode (keypad)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.right)+\(i.rawValue.uppercased) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(.a,.pad0), (.s,.pad1), (.d,.pad2), (.f,.pad3), (.g,.pad4),
            (.q,.pad5), (.w,.pad6), (.e,.pad7), (.r,.pad8), (.t,.pad9),
            (.z,.padPeriod), (.accentGrave,.padSlash), (.x,.padPlus), (.c,.padHyphen), (.v,.padAsterisk), (.b,.padEqual)] )
        
        return [ruleBasic, ruleKeyPad]
    }
    
    private func rulesBoth() -> [Rule] {
        /// Condition to check the "both" state.
        let modeCondition = [ Condition(.are, variableName: mode.left, value: 1, "Check that Left Mode is active"),
                              Condition(.are, variableName: mode.right, value: 1, "Check that Right Mode is active") ]
        
        /// Handle leaps in arrow keys.
        let ruleArrows = Rule("Both mode (arrows)", manipulators: [
            Manipulator("\(mode.left)+\(mode.right)+J -> 15+←", input: Input(keyCode: .j, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .left), count: 15))),
            Manipulator("\(mode.left)+\(mode.right)+I -> 8+↑",  input: Input(keyCode: .i, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .up), count: 8))),
            Manipulator("\(mode.left)+\(mode.right)+K -> 8+↓",  input: Input(keyCode: .k, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .down), count: 8))),
            Manipulator("\(mode.left)+\(mode.right)+L -> 15+→", input: Input(keyCode: .l, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .right), count: 15)))
        ])
        
//        /// Xcode condition
//        let xcode = Condition(.are, frontMostApps: (bundles: ["com.apple.dt.Xcode"], paths: nil), "Check for Xcode as frontmost app")
//
//        /// Rule for navigation around the Xcode editors/areas.
//        let ruleNavigation = Rule("Xcode navigation", manipulators: [
//            Manipulator("Both+F -> ⌘+⌥+Ñ",   input: Input(keyCode: .f, mandatory: .none, optional: .none), conditions: [isRight, isLeft, xcode], outputs: Triggers(press: [Output(keyCode: .semicolon, modifiers: [.command, .option])])),
//            Manipulator("Both+S -> ⌘+⌥+⇧+Ñ", input: Input(keyCode: .s, mandatory: .none, optional: .none), conditions: [isRight, isLeft, xcode], outputs: Triggers(press: [Output(keyCode: .semicolon, modifiers: [.command, .option, .shift])])),
//            Manipulator("Both+E -> ⌘+⌃+Ñ",   input: Input(keyCode: .e, mandatory: .none, optional: .none), conditions: [isRight, isLeft, xcode], outputs: Triggers(press: [Output(keyCode: .semicolon, modifiers: [.command, .control])])),
//            Manipulator("Both+D -> ⌘+⌃+⇧+Ñ", input: Input(keyCode: .d, mandatory: .none, optional: .none), conditions: [isRight, isLeft, xcode], outputs: Triggers(press: [Output(keyCode: .semicolon, modifiers: [.command, .control, .shift])]))
//        ])
        
        return [ruleArrows]
    }
    
    private func rulesShift() -> [Rule] {
        /// Rule for Shift, parentheses, and Caps.
        let ruleBasic = Rule("Shift mode", manipulators: [
            Manipulator("Left Shift -> (",   input: Input(keyCode: .shiftL, mandatory: .none, optional: .none), outputs: Triggers(press: [Output(keyCode: .shiftL)], pressAlone: [Output(keyCode: .eight, modifiers: [.shift])]), parameters: [.pressAlone(seconds: 0.66)]),
            Manipulator("Right Shift -> )",  input: Input(keyCode: .shiftR, mandatory: .none, optional: .none), outputs: Triggers(press: [Output(keyCode: .shiftR)], pressAlone: [Output(keyCode: .nine,  modifiers: [.shift])]), parameters: [.pressAlone(seconds: 0.66)]),
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
        
        /// Rules for Mission Control.
        let ruleMissionControl = Rule("SwiftPoint (mission control)", manipulators: [
            Manipulator("Button8 -> ⌃+←", input: Input(button: .button8), conditions: [isMouse],  outputs: Triggers(press: [Output(keyCode: .left, modifiers: [.control])])),
            Manipulator("Button9 -> ⌃+→", input: Input(button: .button9), conditions: [isMouse],  outputs: Triggers(press: [Output(keyCode: .right, modifiers: [.control])])),
            Manipulator("Button10 -> ⌃+↓", input: Input(button: .button10), conditions: [isMouse], outputs: Triggers(press: [Output(keyCode: .down, modifiers: [.control])])),
            Manipulator("Button11 -> ⌃+↑", input: Input(button: .button11), conditions: [isMouse], outputs: Triggers(press: [Output(keyCode: .up, modifiers: [.control])]))
        ])
        
        /// Rules for miscellanea services.
        let ruleMisc = Rule("SwiftPoint (misc)", manipulators: [
            Manipulator("Button12 -> ⌘+⇧+4", input: Input(button: .button12), conditions: [isMouse],  outputs: Triggers(press: [Output(keyCode: .four, modifiers: [.command, .shift])])),
            Manipulator("Button13 -> ⌘+⌥+8", input: Input(button: .button13), conditions: [isMouse],  outputs: Triggers(press: [Output(keyCode: .eight, modifiers: [.command, .option])])),
        ])
        
        return [ruleTabs, ruleMissionControl, ruleMisc]
    }
}
