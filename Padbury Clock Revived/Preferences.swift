//
//  Preferences.swift
//  Padbury Clock Revived
//
//  Created by Hans Schülein on 3.2.2021.
//

import Foundation
import ScreenSaver

class Preferences: NSObject {

    static var shared: Preferences? = nil

    private let defaults: UserDefaults

    override init() {
        defaults = ScreenSaverDefaults(forModuleWithName: Bundle(for: Preferences.self).bundleIdentifier!)!
        super.init()
        Preferences.shared = self
    }

    var useSystemFont: Bool {
        get { return (defaults.value(forKey: "UseSystemFont") as? Bool) ?? true }
        set {
            defaults.setValue(newValue, forKey: "UseSystemFont")
            defaults.synchronize()
        }
    }

    var darkTheme: Bool {
        get { return (defaults.value(forKey: "DarkTheme") as? Bool) ?? true }
        set {
            defaults.setValue(newValue, forKey: "DarkTheme")
            defaults.synchronize()
        }
    }
    
    var nightTimeMode: Bool {
        get { return (defaults.value(forKey: "NightTimeMode") as? Bool) ?? false }
        set {
            defaults.setValue(newValue, forKey: "NightTimeMode")
            defaults.synchronize()
        }
    }

    var useAmPm: Bool {
        get { return !((defaults.value(forKey: "24h") as? Bool) ?? true) }
        set {
            defaults.setValue(!newValue, forKey: "24h")
            defaults.synchronize()
        }
    }

    var showTimeSeparators: Bool {
        get { return (defaults.value(forKey: "showTimeSeparators") as? Bool) ?? false }
        set {
            defaults.setValue(newValue, forKey: "showTimeSeparators")
            defaults.synchronize()
        }
    }

    var fontWeight: NSFont.Weight {
        get { return NSFont.Weight.from(name: (defaults.value(forKey: "fontWeight") as? String) ?? "Ultra Light") }
        set {
            defaults.setValue(newValue.name, forKey: "fontWeight")
            defaults.synchronize()
        }
    }

    var showSeconds: Bool {
        get { return (defaults.value(forKey: "ShowSeconds") as? Bool) ?? true }
        set {
            defaults.setValue(newValue, forKey: "ShowSeconds")
            defaults.synchronize()
        }
    }
}

// MARK: - NSFont.Weight Names

extension NSFont.Weight {
    var name: String {
        get {
            switch self {
            case .ultraLight:   return "Ultra Light"
            case .thin:         return "Thin"
            case .light:        return "Light"
            case .regular:      return "Regular"
            case .medium:       return "Medium"
            case .semibold:     return "Semibold"
            case .bold:         return "Bold"
            case .heavy:        return "Heavy"
            case .black:        return "Black"
            default:            return "Regular"
            }
        }
    }

    static func from(name: String) -> NSFont.Weight {
        switch name {
        case "Ultra Light": return .ultraLight
        case "Thin":        return .thin
        case "Light":       return .light
        case "Regular":     return .regular
        case "Medium":      return .medium
        case "Semibold":    return .semibold
        case "Bold":        return .bold
        case "Heavy":       return .heavy
        case "Black":       return .black
        default:            return .regular
        }
    }
}
