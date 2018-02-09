import XCTest
@testable import Karabiner

class MarcosTests: XCTestCase {
    /// Modes names
    let mode: (left: String, right: String, shift: String) = ("mode_left", "mode_right", "mode_shift")

    /// Test executing all rules used by [Marcos](https://github.com/dehesa).
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
        let ruleTrigger = Rule("Left mode", manipulators: [
            Manipulator("Caps -> \(mode.left)", input: Input(keyCode: .caps, optional: .any), outputs: Triggers(press: [Output(variable: mode.left, value: 1)], release: [Output(variable: mode.left, value: 0)]) )
        ])
        
        /// Condition that checks whether the left mode is active.
        let modeCondition = [ Condition(.are, variableName: mode.left,  value: 1, "Check that Left Mode is active"),
                              Condition(.are, variableName: mode.right, value: 0, "Check that Right Mode is inactive") ]
        
        /// Rule to handle the arrow keys.
        let ruleArrows = Rule("Left mode (arrows)", manipulators: [
            Manipulator("\(mode.left)+J -> ←", input: Input(keyCode: .j, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .left)])),
            Manipulator("\(mode.left)+I -> ↑", input: Input(keyCode: .i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .up)])),
            Manipulator("\(mode.left)+K -> ↓", input: Input(keyCode: .k, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .down)])),
            Manipulator("\(mode.left)+L -> →", input: Input(keyCode: .l, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .right)]))
        ])
        
        /// Rule to handle Delete and Enter.
        let ruleDelete = Rule("Left mode (delete, enter, escape)", manipulators: [
            Manipulator("\(mode.left)+Space", input: Input(keyCode: .space,     optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .enter)])),
            Manipulator("\(mode.left)+Ñ",     input: Input(keyCode: .semicolon, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .deleteBack)])),
            Manipulator("\(mode.left)+Slash", input: Input(keyCode: .slash,     optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .deleteForward)])),
            Manipulator("\(mode.left)+H",     input: Input(keyCode: .h,         optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .escape)]))
        ])
        
        /// Rule to handle tab switching.
        let ruleTabs = Rule("Left mode (tab switching)", manipulators: [
            Manipulator("\(mode.left)+Tab", input: Input(keyCode: .tab, optional: .modifiers([.shift, .option, .command, .fn])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control])]))
        ])
        
        /// Rule to handle f# keys.
        let ruleFn = { (pairs) -> Rule in
            Rule("Left mode (F#)", manipulators: pairs.map { (i, o) in
                Manipulator("\(mode.left)+\(i.rawValue) -> \(o.rawValue)", input: Input(keyCode: i, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: o)]))
            })
        }( [(Keyboard.Key.one,Keyboard.Key.f1), (.two,.f2), (.three,.f3), (.four,.f4), (.five,.f5), (.six,.f6), (.seven,.f7), (.eight,.f8), (.nine,.f9), (.zero,.f10), (.hyphen,.f11), (.equal,.f12), (.deleteBack,.f13)] )
        
        /// Rules for Spectacle (with modified keyboard shortcuts).
        let ruleSpectacle = Rule("Left mode (spectacle)", manipulators: [
            Manipulator("\(mode.left)+S -> Center",      input: Input(keyCode: .s, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .s, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+F -> Full screnn", input: Input(keyCode: .f, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .f, modifiers: [.control, .option, .shift, .command])])),
            
            Manipulator("\(mode.left)+A -> Left half",   input: Input(keyCode: .a, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .a, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+D -> Right half",  input: Input(keyCode: .d, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .d, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+W -> Top half",    input: Input(keyCode: .w, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .w, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+X -> Bottom half", input: Input(keyCode: .x, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .x, modifiers: [.control, .option, .shift, .command])])),
            
            Manipulator("\(mode.left)+Q -> Upper left",  input: Input(keyCode: .q, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .c, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+E -> Upper right", input: Input(keyCode: .e, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .e, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+Z -> Lower left",  input: Input(keyCode: .z, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .z, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+C -> Lower right", input: Input(keyCode: .c, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .b, modifiers: [.control, .option, .shift, .command])])),
            
            Manipulator("\(mode.left)+R -> Make larger",  input: Input(keyCode: .r, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .m, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+V -> Make smaller", input: Input(keyCode: .v, optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .n, modifiers: [.control, .option, .shift, .command])])),
            
            Manipulator("\(mode.left)+⌘+S -> Mission Control",       input: Input(keyCode: .s, mandatory: .modifiers([.command]), optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .i, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+⌘+F -> Full screnn (Display)", input: Input(keyCode: .f, mandatory: .modifiers([.command]), optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .f, modifiers: [.control, .command])])),
            Manipulator("\(mode.left)+⌘+D -> Next display",          input: Input(keyCode: .d, mandatory: .modifiers([.command]), optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .r, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+⌘+A -> Previous display",      input: Input(keyCode: .a, mandatory: .modifiers([.command]), optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .v, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+⌥+D -> Move right a space",    input: Input(keyCode: .d, mandatory: .modifiers([.option]),  optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .o, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+⌥+A -> Move lef a space",      input: Input(keyCode: .a, mandatory: .modifiers([.option]),  optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .u, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+⌥+W -> Make window larger",    input: Input(keyCode: .w, mandatory: .modifiers([.option]),  optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .m, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("\(mode.left)+⌥+X -> Make window smaller",   input: Input(keyCode: .x, mandatory: .modifiers([.option]),  optional: .modifiers([.caps])), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .n, modifiers: [.control, .option, .shift, .command])]))
        ])
        
        return [ruleTrigger, ruleArrows, ruleDelete, ruleTabs, ruleFn, ruleSpectacle]
    }
    
    /// Rules that are triggered once the "Right" mode is active (a.k.a. The "Quote" key is pressed).
    /// - returns The rule identifying the "Right" mode and all other rules associated exclusively with it.
    private func rulesRight() -> [Rule] {
        /// Rule that triggers the right mode.
        let ruleTrigger = Rule("Right mode", manipulators: [
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
        
        /// Rule to handle Delete and Enter.
        let ruleDelete = Rule("Right mode (delete, enter, escape)", manipulators: [
            Manipulator("\(mode.left)+Space", input: Input(keyCode: .space,     optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .enter)])),
            Manipulator("\(mode.left)+Ñ",     input: Input(keyCode: .semicolon, optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .deleteBack)])),
            Manipulator("\(mode.left)+Slash", input: Input(keyCode: .slash,     optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .deleteForward)])),
            Manipulator("\(mode.left)+H",     input: Input(keyCode: .h,         optional: .any), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .escape)]))
        ])
        
        return [ruleTrigger, ruleKeyPad, ruleDelete]
    }
    
    /// Rules that are triggered once the "Left" and "Right" mode are active (a.k.a. The "Caps" and "Quote" keys are pressed).
    /// - returns The rule identifying the "Both" mode and all other rules associated exclusively with it.
    private func rulesBoth() -> [Rule] {
        /// Condition to check the "both" state.
        let modeCondition = [ Condition(.are, variableName: mode.left, value: 1, "Check that Left Mode is active"),
                              Condition(.are, variableName: mode.right, value: 1, "Check that Right Mode is active") ]
        
        /// Handle leaps in arrow keys.
        let ruleArrows = Rule("Both mode (arrows)", manipulators: [
            Manipulator("\(mode.left)+\(mode.right)+J -> 15+←", input: Input(keyCode: .j, optional: .any), conditions: modeCondition, outputs: Triggers(press: Array(repeating: Output(keyCode: .left), count: 15))),   // TODO: This doesn't seem to work.
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
    
    /// Rules triggered once the left and right shift are pressed/released simultaneously.
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
    
    /// Rules specialized for the [SwifPoint mouse](https://www.swiftpoint.com/limited-drop?mc_cid=67bf478fe4&mc_eid=77a9304e90).
    private func rulesMouse() -> [Rule] {
        /// Condition to detect the SwiftPoint mouse.
        let modeCondition = [ Condition(.are, deviceIdentifiers: [(8526, 5, "SwiftPoint mouse")]) ]
        
        /// Rule for managing "tabs" on applications.
        let ruleTabs = Rule("SwiftPoint (tab switching)", manipulators: [
            Manipulator("Button5 -> ⌃+Tab", input: Input(button: .button5), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control])])),
            Manipulator("Button4 -> ⌃+⇧+Tab", input: Input(button: .button4), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .tab, modifiers: [.control, .shift])]))
        ])
        
        /// Rule for close/quit apps.
        let ruleQuit = Rule("SwiftPoint (quit)", manipulators: [
            Manipulator("Button6 -> ⌘+W", input: Input(button: .button6), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .w, modifiers: [.command])])),
            Manipulator("Button7 -> ⌘+Q", input: Input(button: .button7), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .q, modifiers: [.command])]))
        ])
        
        /// Rule for Mission Control -> Spectacle (modified shortcuts).
        let ruleMissionControl = Rule("SwiftPoint (mission control)", manipulators: [
            Manipulator("Button8 -> ⌘+⌃+⌥+⇧+U", input: Input(button: .button8), conditions: modeCondition,  outputs: Triggers(press: [Output(keyCode: .u, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("Button9 -> ⌘+⌃+⌥+⇧+O", input: Input(button: .button9), conditions: modeCondition,  outputs: Triggers(press: [Output(keyCode: .o, modifiers: [.control, .option, .shift, .command])])),

            Manipulator("Button11 -> ⌘+⌃+⌥+⇧+I", input: Input(button: .button11), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .i, modifiers: [.control, .option, .shift, .command])])),
            Manipulator("Button10 -> ESC", input: Input(button: .button10), conditions: modeCondition, outputs: Triggers(press: [Output(keyCode: .escape)]))
        ])
        
        /// Rules for miscellanea services.
        let ruleMisc = Rule("SwiftPoint (misc)", manipulators: [
            Manipulator("Button12 -> ⌘+⇧+4", input: Input(button: .button12), conditions: modeCondition,  outputs: Triggers(press: [Output(keyCode: .four, modifiers: [.command, .shift])])),
            Manipulator("Button13 -> ⌘+⌥+8", input: Input(button: .button13), conditions: modeCondition,  outputs: Triggers(press: [Output(keyCode: .eight, modifiers: [.command, .option])])),
        ])
        
        return [ruleTabs, ruleQuit, ruleMissionControl, ruleMisc]
    }
}
