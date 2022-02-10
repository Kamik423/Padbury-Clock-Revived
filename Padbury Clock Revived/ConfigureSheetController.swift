//
//  ConfigureSheetController.swift
//  Padbury Clock Revived
//
//  Created by Hans Schülein on 2.2.2021.
//
//

import Cocoa

class ConfigureSheetController: NSObject {

    @IBOutlet var window: NSWindow?
    
    @IBOutlet var versionStringLabel: NSTextField!
    
    @IBOutlet var darkThemeCheckbox: NSButton!
    @IBOutlet var nightTimeModeCheckbox: NSButton!
    @IBOutlet var twentyfourHoursCheckbox: NSButton!
    @IBOutlet var showSecondsCheckbox: NSButton!
    @IBOutlet var showTimeSeparatorsCheckbox: NSButton!
    @IBOutlet var fontSelector: NSPopUpButton!
    @IBOutlet var fontWeightSelector: NSPopUpButton!
    
    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        let bundle = Bundle(for: ConfigureSheetController.self)
        versionStringLabel.stringValue = "v\(bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "???") b\(bundle.object(forInfoDictionaryKey: "CFBundleVersion") ?? "?")"
        
        if let preferences = Preferences.shared {
            darkThemeCheckbox.state = preferences.darkTheme ? .on : .off
            nightTimeModeCheckbox.state = preferences.nightTimeMode ? .on : .off
            twentyfourHoursCheckbox.state = preferences.useAmPm ? .off : .on
            showSecondsCheckbox.state = preferences.showSeconds ? .on : .off
            showTimeSeparatorsCheckbox.state = preferences.showTimeSeparators ? .on : .off
            fontSelector.selectItem(withTitle: preferences.font.name)
            
            fontSelector.removeAllItems()
            let availableFonts: [String] = SupportedFonts.allCases.map { $0.name }
            for font in availableFonts {
                fontSelector.addItem(withTitle: font)
            }
            fontSelector.selectItem(withTitle: preferences.font.name)
            
            fontWeightSelector.removeAllItems()
            for fontWeight in preferences.font.availableWeights {
                fontWeightSelector.addItem(withTitle: fontWeight.name)
            }
            fontWeightSelector.selectItem(at: preferences.font.availableWeights.firstIndex(of: preferences.fontWeight) ?? 0)
            preferences.fontWeight = NSFont.Weight.from(name: fontWeightSelector.selectedItem?.title ?? "")
            
            ClockView.shared?.setup(force: true)
        }
    }
    
    @IBAction func toggledCheckbox(_ sender: NSObject) {
        if let preferences = Preferences.shared {
            preferences.darkTheme = darkThemeCheckbox.state == .on
            preferences.nightTimeMode = nightTimeModeCheckbox.state == .on
            preferences.useAmPm = twentyfourHoursCheckbox.state == .off
            preferences.showSeconds = showSecondsCheckbox.state == .on
            preferences.showTimeSeparators = showTimeSeparatorsCheckbox.state == .on
            preferences.font = SupportedFonts.named(fontSelector.selectedItem?.title ?? "")
            preferences.fontWeight = NSFont.Weight.from(name: fontWeightSelector.selectedItem?.title ?? "")
            
            self.setup()
        }
    }
    
    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        window?.sheetParent?.endSheet(window!)
    }
    
    @IBAction func openGithubLink(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/Kamik423/Padbury-Clock-Revived")!)
    }
}
