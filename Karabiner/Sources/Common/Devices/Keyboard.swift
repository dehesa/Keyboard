import Foundation

/// Namespace for everything physical keyboard related.
public enum Keyboard {
    /// Enumeration of all keyboard keys (identified by their names).
    /// The modifier keys are not included.
    /// - notes: For more keys, check: https://github.com/tekezo/Karabiner-Elements/issues/925
    public enum Key: String, Codable {
        // Keys by keyboard rows
        case accentGrave="grave_accent_and_tilde", one="1", two="2", three="3", four="4", five="5", six="6", seven="7", eight="8", nine="9", zero="0", hyphen="hyphen", equal="equal_sign", backspace="delete_or_backspace"
        case tab, q, w, e, r, t, y, u, i, o, p, bracketOpen="open_bracket", bracketClose="close_bracket"
        case a, s, d, f, g, h, j, k, l, semicolon, quote, backslash, enter="return_or_enter"
        case backslashAlternate="non_us_backslash", z, x, c, v, b, n, m, comma, period, slash, space="spacebar"
        // Arrow keys
        case up="up_arrow", down="down_arrow", left="left_arrow", right="right_arrow", pageUp="page_up", pageDown="page_down", home, end
        // Function keys
        case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24
        // Keypad keys
        case padNumLock="keypad_num_lock", padSlash="keypad_slash", padAsterisk="keypad_asterisk", padHyphen="keypad_hyphen", padPlus="keypad_plus", padEnter="keypad_enter"
        case pad1="keypad_1", pad2="keypad_2", pad3="keypad_3", pad4="keypad_4", pad5="keypad_5", pad6="keypad_6", pad7="keypad_7", pad8="keypad_8", pad9="keypad_9", pad0="keypad_0"
        case padPeriod="keypad_period", padEqual="keypad_equal_sign", padComma="keypad_comma"
        // Media controls
        case displayBrightnessDown="display_brightness_decrement", displayBrightnessUp="display_brightness_increment", illuminationDown="illumination_decrement", illuminationUp="illumination_increment"
        case missionControl="mission_control", launchpad, dashboard, eject
        case rewind, play="play_or_pause", fastForward="fastforward", mute, volumeDown="volume_decrement", volumeUp="volume_increment"
        case appleDisplayBrightnessDown="apple_display_brightness_decrement", appleDisplayBrightnessUp="apple_display_brightness_increment"
        case appleTopCaseDisplayBrightnessDown="apple_top_case_display_brightness_decrement", appleDisplayTopCaseBrightnessUp="apple_top_case_display_brightness_increment"
    }
    
    /// List of all keyboard modifier keys.
    public enum Modifier: String, Codable {
        case caps = "caps_lock"
        case shift, shiftL = "left_shift", shiftR = "right_shift"
        case control, controlL = "left_control", controlR = "right_control"
        case option, optionL = "left_option", optionR = "right_option"
        case command, commandL = "left_command", commandR = "right_command"
        case fn
    }
}

internal extension Set where Element==Keyboard.Modifier {
    /// Filter out similar elements if they are already in the set.
    ///
    /// For example, if `control` is specified, you can filter out left control and right control.
    internal func filterSimilars() -> Set<Keyboard.Modifier> {
        // If there is no elements or just one, return the set.
        guard self.count > 1 else { return self }
        
        var result = self
        
        if result.contains(.shift) {
            result.subtract([.shiftL, .shiftR])
        }
        
        if result.contains(.control) {
            result.subtract([.controlL, .controlR])
        }
        
        if result.contains(.option) {
            result.subtract([.optionL, .optionR])
        }
        
        if result.contains(.command) {
            result.subtract([.commandL, .commandR])
        }
        
        return result
    }
}
