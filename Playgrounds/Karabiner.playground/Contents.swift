import Foundation
//import Karabiner

func hasPrefix(_ prefix: String) -> (String)->Bool {
    return { (value) in value.hasPrefix(prefix) }
}

func hasSuffix(_ suffix: String) -> (String)->Bool {
    return { (value) in value.hasSuffix(suffix) }
}

func ~=<T>(pattern: (T) -> Bool, value: T) -> Bool {
    return pattern(value)
}

switch "https://www.wikipedia.org" {
case hasPrefix("mqtt"): print("Is MQTT")
case hasPrefix("http"): print("Is HTTP")
default: break
}

