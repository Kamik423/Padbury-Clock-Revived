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
    
    var fontFamily: SupportedFont {
        // Which font should be used
        get { return SupportedFont.named(defaults.value(forKey: "FontFamily") as? String ?? "") }
        set {
            defaults.setValue(newValue.name, forKey: "FontFamily")
            defaults.synchronize()
        }
    }
    
    func nsFont(ofSize fontSize: CGFloat) -> NSFont {
        // The NSFont to use with correct weight and size set
        let fallback = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
        
        // Load the font
        guard var font = NSFont(name: fontFamily.postscriptName(for: styleName) ?? "", size: fontSize) else { return fallback }
        // Apply TrueType stylistic sets to get proportional numbers.
        var featureSettings: [[NSFontDescriptor.FeatureKey: Int]] = [[.typeIdentifier: kNumberSpacingType, .selectorIdentifier: kMonospacedNumbersSelector]]
        if fontFamily == .neueHelvetica {
            // Alternate Punctuation (rounded, raised colon)
            featureSettings.append([.typeIdentifier: kCharacterAlternativesType, .selectorIdentifier: 1])
        }
        // Alternative fontfeatures can be determined using
        // CTFontCopyFeatures(NSFont(name: ".AppleSystemUIFont", size: 10)!)
        // SF supports open 4, straight 6 and 9
        // NY supports old style
        
        // Apply the attributes
        font = NSFont(descriptor: font.fontDescriptor.addingAttributes([.featureSettings: featureSettings]), size: 0.0) ?? font
        return font
    }
    
    var plainFontsOnly: Bool {
        // Only use Regular Width Roman Fonts
        get { return (defaults.value(forKey: "PlainFontsOnly") as? Bool) ?? true }
        set {
            defaults.setValue(newValue, forKey: "PlainFontsOnly")
            defaults.synchronize()
        }
    }

    var appearance: Appearance {
        // Should the dark theme be used
        get { return Appearance(rawValue: defaults.value(forKey: "appearance") as? String ?? "") ?? .dark }
        set {
            defaults.setValue(newValue.rawValue, forKey: "appearance")
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

    var styleName: String {
        // The font weight to be used
        get { return defaults.value(forKey: "styleName") as? String ??  "UltraLight" }
        set {
            defaults.setValue(newValue, forKey: "styleName")
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

// MARK: - Dark Mode Enum

enum Appearance: String, CaseIterable {
    case dark
    case light
    case system
    
    var title: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .system:
            return "System"
        }
    }
    
    static func titled(_ title: String) -> Appearance? {
        return Appearance.allCases.first(where: { $0.title == title })
    }
}

// MARK: - Supported Fonts Enum

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
    
    var fontFamilyName: String {
        // The name of the font family ".AppleSystemUIFontUltraLight"
        switch self {
        case .sanFrancisco:
            return ".AppleSystemUIFont"
        case .sanFranciscoMono:
            return ".AppleSystemUIFontMonospaced"
        case .newYork:
            return ".AppleSystemUIFontSerif"
        case .neueHelvetica:
            return "Helvetica Neue"
        }
    }
    
    static func named(_ name: String) -> SupportedFont {
        // Get the font from the name
        SupportedFont.allCases.first(where: { $0.name == name }) ?? .sanFrancisco
    }
    
    var availableWeights: [String] {
        // List of available font weights for each font
        return (NSFontManager.shared.availableMembers(ofFontFamily: self.fontFamilyName)?.filter({ !(Preferences.shared?.plainFontsOnly ?? true) || Int(truncating: $0[3] as? NSNumber ?? 0)&0b1000001 == 0 }).map({ $0[1] as? String ?? "Error" })) ?? []
    }
    
    func postscriptName(for styleName: String) -> String? {
        // Get
        return NSFontManager.shared.availableMembers(ofFontFamily: self.fontFamilyName)?.first(where: { $0[1] as? String == styleName })?[0] as? String
    }
}
