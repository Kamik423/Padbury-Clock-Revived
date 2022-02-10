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
        // Configure Defaults for bundle
        defaults = ScreenSaverDefaults(forModuleWithName: Bundle(for: Preferences.self).bundleIdentifier!)!
        super.init()
        Preferences.shared = self
    }
    
    var font: SupportedFont {
        // Which font should be used
        get { return SupportedFont.named(defaults.value(forKey: "Font") as? String ?? "") }
        set {
            defaults.setValue(newValue.name, forKey: "Font")
            defaults.synchronize()
        }
    }
    
    func nsFont(ofSize fontSize: CGFloat) -> NSFont {
        // The NSFont to use with correct weight and size set
        let fallback = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        switch font {
        case .sanFrancisco:
            // Default system font
            return .monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
        case .sanFranciscoMono:
            // Monospace default system font
            return .monospacedSystemFont(ofSize: fontSize, weight: fontWeight)
        case .newYork:
            // Serif default system font
            let descriptor = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight).fontDescriptor
            return NSFont(descriptor: descriptor.withDesign(.serif) ?? descriptor, size: 0.0) ?? fallback
        case .neueHelvetica:
            // Neue Helvetica
            // Get the name of the font file to load
            let fontName: String
            switch fontWeight {
            case .ultraLight:
                fontName = "Helvetica Neue UltraLight"
            case .thin:
                fontName = "Helvetica Neue Thin"
            case .light:
                fontName = "Helvetica Neue Light"
            case .regular:
                fontName = "Helvetica Neue"
            case .medium:
                fontName = "Helvetica Neue Medium"
            case .bold:
                fontName = "Helvetica Neue Bold"
            default:
                fontName = "Helvetica Neue"
            }
            // Load the font
            guard var font = NSFont(name: fontName, size: fontSize) else { return fallback }
            // Apply TrueType stylistic sets to get proportional numbers and the raised colon.
            let fontAttributes: [NSFontDescriptor.AttributeName: Any] = [
                .featureSettings: [
                    [
                        // Proportional Numbers
                        NSFontDescriptor.FeatureKey.typeIdentifier: 6,
                        NSFontDescriptor.FeatureKey.selectorIdentifier: 1
                    ],
                    [
                        // Alternate Punctuation (rounded, raised colon)
                        NSFontDescriptor.FeatureKey.typeIdentifier: 17,
                        NSFontDescriptor.FeatureKey.selectorIdentifier: 1
                    ]
                 ]
            ]
            // Apply the attributes
            font = NSFont(descriptor: font.fontDescriptor.addingAttributes(fontAttributes), size: 0.0) ?? font
            return font
        }
    }

    var darkTheme: Bool {
        // Should the dark theme be used
        get { return (defaults.value(forKey: "DarkTheme") as? Bool) ?? true }
        set {
            defaults.setValue(newValue, forKey: "DarkTheme")
            defaults.synchronize()
        }
    }
    
    var nightTimeMode: Bool {
        // Should the night time mode be used that makes the font red at night
        get { return (defaults.value(forKey: "NightTimeMode") as? Bool) ?? false }
        set {
            defaults.setValue(newValue, forKey: "NightTimeMode")
            defaults.synchronize()
        }
    }

    var useAmPm: Bool {
        // Use AM/PM or 24h time
        get { return !((defaults.value(forKey: "24h") as? Bool) ?? true) }
        set {
            defaults.setValue(!newValue, forKey: "24h")
            defaults.synchronize()
        }
    }

    var showTimeSeparators: Bool {
        // Show the time separators (colons)
        get { return (defaults.value(forKey: "showTimeSeparators") as? Bool) ?? false }
        set {
            defaults.setValue(newValue, forKey: "showTimeSeparators")
            defaults.synchronize()
        }
    }

    var fontWeight: NSFont.Weight {
        // The font weight to be used
        get { return NSFont.Weight.from(name: (defaults.value(forKey: "fontWeight") as? String) ?? "Ultra Light") }
        set {
            defaults.setValue(newValue.name, forKey: "fontWeight")
            defaults.synchronize()
        }
    }

    var showSeconds: Bool {
        // Should seconds be displayed or just HH and MM
        get { return (defaults.value(forKey: "ShowSeconds") as? Bool) ?? true }
        set {
            defaults.setValue(newValue, forKey: "ShowSeconds")
            defaults.synchronize()
        }
    }
    
    var mainScreenOnly: Bool {
        // Show the time only on the main screen
        get { return (defaults.value(forKey: "MainScreenOnly") as? Bool) ?? false }
        set {
            defaults.setValue(newValue, forKey: "MainScreenOnly")
            defaults.synchronize()
        }
    }
}

// MARK: - Supported Fonts ENum

enum SupportedFont: String, CaseIterable {
    // Enum of the supported fonts
    case sanFrancisco
    case sanFranciscoMono
    case newYork
    case neueHelvetica
    
    var name: String {
        // Get the name of the font for UI and storing purposes
        switch self {
        case .sanFrancisco:
            return "San Francisco (System Font)"
        case .sanFranciscoMono:
            return "San Francisco Mono"
        case .newYork:
            return "New York"
        case .neueHelvetica:
            return "Neue Helvetica (Padbury Original)"
        }
    }
    
    static func named(_ name: String) -> SupportedFont {
        // Get the font from the name
        SupportedFont.allCases.first(where: { $0.name == name }) ?? .sanFrancisco
    }
    
    var availableWeights: [NSFont.Weight] {
        // List of available font weights for each font
        switch self {
        case .sanFrancisco:
            return [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
        case .sanFranciscoMono:
            return [.light, .regular, .medium, .semibold, .bold, .heavy, .black]
        case .newYork:
            return [.regular, .medium, .semibold, .bold, .heavy, .black]
        case .neueHelvetica:
            return [.ultraLight, .thin, .light, .regular, .medium, .bold]
        }
    }
}

// MARK: - NSFont.Weight Names

extension NSFont.Weight {
    var name: String {
        // Names for font weights
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
        // Font weight from name
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
