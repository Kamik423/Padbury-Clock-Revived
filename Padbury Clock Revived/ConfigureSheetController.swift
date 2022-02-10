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
    
    // Outlets for the checkboxes to use
    @IBOutlet var versionStringLabel: NSTextField!
    
    @IBOutlet var darkThemeCheckbox: NSButton!
    @IBOutlet var nightTimeModeCheckbox: NSButton!
    @IBOutlet var twentyfourHoursCheckbox: NSButton!
    @IBOutlet var showSecondsCheckbox: NSButton!
    @IBOutlet var showTimeSeparatorsCheckbox: NSButton!
    @IBOutlet var fontSelector: NSPopUpButton!
    @IBOutlet var fontWeightSelector: NSPopUpButton!
    @IBOutlet var mainScreenCheckbox: NSButton!
    
    override init() {
        super.init()
        // Load the UI
        Bundle(for: ConfigureSheetController.self).loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        // Display the version number in the corner
        let bundle = Bundle(for: ConfigureSheetController.self)
        let versionNumber = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "?.?.?"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") ?? "?"
        versionStringLabel.stringValue = "v\(versionNumber) b\(buildNumber)"
        
        // Continue only if the preferences can be loaded
        guard let preferences = Preferences.shared else { return }
        
        // Set the checkboxes according to the settings
        darkThemeCheckbox.state = preferences.darkTheme ? .on : .off
        nightTimeModeCheckbox.state = preferences.nightTimeMode ? .on : .off
        twentyfourHoursCheckbox.state = preferences.useAmPm ? .off : .on
        showSecondsCheckbox.state = preferences.showSeconds ? .on : .off
        showTimeSeparatorsCheckbox.state = preferences.showTimeSeparators ? .on : .off
        fontSelector.selectItem(withTitle: preferences.font.name)
        mainScreenCheckbox.state = preferences.mainScreenOnly ? .on : .off
        
        // Remove all options from the font selector and add the ones corresponding to the fonts
        fontSelector.removeAllItems()
        fontSelector.addItems(withTitles: SupportedFont.allCases.map { $0.name })
        fontSelector.selectItem(withTitle: preferences.font.name)
        
        // Remove all the options from the font weight selector
        // and add the ones corresponding to the current font
        fontWeightSelector.removeAllItems()
        fontWeightSelector.addItems(withTitles: preferences.font.availableWeights.map({ $0.name }))
        // Select the correct item
        // If the weight is not available for this font select the first option
        fontWeightSelector.selectItem(at: preferences.font.availableWeights.firstIndex(where: { $0.name == preferences.fontWeight.name }) ?? 0 )
        // Store said option back to the settings in case it changed
        preferences.fontWeight = NSFont.Weight.from(name: fontWeightSelector.selectedItem?.title ?? "")
        
        // Trigger update of the preview window
        ClockView.shared?.setup(force: true)
    }
    
    @IBAction func toggledCheckbox(_ sender: NSObject) {
        // Write all settings once one was changed.
        
        // Continue only if the preferences can be loaded correctly
        guard let preferences = Preferences.shared else { return }
        
        preferences.darkTheme = darkThemeCheckbox.state == .on
        preferences.nightTimeMode = nightTimeModeCheckbox.state == .on
        preferences.useAmPm = twentyfourHoursCheckbox.state == .off
        preferences.showSeconds = showSecondsCheckbox.state == .on
        preferences.showTimeSeparators = showTimeSeparatorsCheckbox.state == .on
        preferences.font = SupportedFont.named(fontSelector.selectedItem?.title ?? "")
        preferences.fontWeight = NSFont.Weight.from(name: fontWeightSelector.selectedItem?.title ?? "")
        preferences.mainScreenOnly = mainScreenCheckbox.state == .on
        
        // Update the options. Font weight might have changed.
        self.setup()
    }
    
    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        // Close the sheet
        window?.sheetParent?.endSheet(window!)
    }
    
    @IBAction func openGithubLink(_ sender: Any) {
        // Open the link to the GitHub repository
        NSWorkspace.shared.open(URL(string: "https://github.com/Kamik423/Padbury-Clock-Revived")!)
    }
}
