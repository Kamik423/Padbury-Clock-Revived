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
    
    var font: SupportedFonts {
        get { return SupportedFonts.named(defaults.value(forKey: "Font") as? String ?? "") }
        set {
            defaults.setValue(newValue.name, forKey: "Font")
            defaults.synchronize()
        }
    }
    
    func nsFont(ofSize fontSize: CGFloat) -> NSFont {
        let fallback = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        switch font {
        case .sanFrancisco:
            return .monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        case .sanFranciscoMono:
            return .monospacedSystemFont(ofSize: fontSize, weight: fontWeight)
        case .newYork:
            let descriptor = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight).fontDescriptor
            return NSFont(descriptor: descriptor.withDesign(.serif) ?? descriptor, size: 0.0) ?? fallback
        case .helveticaNeue:
            let fontName: String
            switch fontWeight {
            case .ultraLight:   fontName = "Helvetica Neue UltraLight"
            case .thin:         fontName = "Helvetica Neue Thin"
            case .light:        fontName = "Helvetica Neue Light"
            case .regular:      fontName = "Helvetica Neue"
            case .medium:       fontName = "Helvetica Neue Medium"
            case .bold:         fontName = "Helvetica Neue Bold"
            default:            fontName = "Helvetica Neue"
            }
            return NSFont(name: fontName, size: fontSize) ?? fallback
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

// MARK: - Supported Fonts ENum

enum SupportedFonts: String, CaseIterable {
    case sanFrancisco
    case sanFranciscoMono
    case newYork
    case helveticaNeue
    
    var name: String {
        switch self {
        case .sanFrancisco:
            return "San Francisco (System Font)"
        case .sanFranciscoMono:
            return "San Francisco Mono"
        case .newYork:
            return "New York"
        case .helveticaNeue:
            return "Helvetica Neue (Padbury Original)"
        }
    }
    
    static func named(_ name: String) -> SupportedFonts {
        SupportedFonts.allCases.first(where: { $0.name == name }) ?? .sanFrancisco
    }
    
    var availableWeights: [NSFont.Weight] {
        switch self {
        case .sanFrancisco:
            return [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
        case .sanFranciscoMono:
            return [.light, .regular, .medium, .semibold, .bold, .heavy, .black]
        case .newYork:
            return [.regular, .medium, .semibold, .bold, .heavy, .black]
        case .helveticaNeue:
            return [.ultraLight, .thin, .light, .regular, .medium, .bold]
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
