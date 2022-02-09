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
    
    @IBOutlet var darkThemeCheckbox: NSButton!
    @IBOutlet var nightTimeModeCheckbox: NSButton!
    @IBOutlet var twentyfourHoursCheckbox: NSButton!
    @IBOutlet var showSecondsCheckbox: NSButton!
    @IBOutlet var showTimeSeparatorsCheckbox: NSButton!
    @IBOutlet var useSystemFontCheckbox: NSButton!
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
        if let preferences = Preferences.shared {
            darkThemeCheckbox.state = preferences.darkTheme ? .on : .off
            nightTimeModeCheckbox.state = preferences.nightTimeMode ? .on : .off
            twentyfourHoursCheckbox.state = preferences.useAmPm ? .off : .on
            showSecondsCheckbox.state = preferences.showSeconds ? .on : .off
            showTimeSeparatorsCheckbox.state = preferences.showTimeSeparators ? .on : .off
            useSystemFontCheckbox.state = preferences.useSystemFont ? .on : .off
            
            fontWeightSelector.removeAllItems()
            let availableFontWeights: [NSFont.Weight] = preferences.useSystemFont ?
                [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black] :
                [.ultraLight, .thin, .light, .regular, .medium, .bold]
            for fontWeight in availableFontWeights {
                fontWeightSelector.addItem(withTitle: fontWeight.name)
            }
            fontWeightSelector.selectItem(at: availableFontWeights.firstIndex(of: preferences.fontWeight) ?? 0)
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
            preferences.useSystemFont = useSystemFontCheckbox.state == .on
            preferences.fontWeight = NSFont.Weight.from(name: fontWeightSelector.selectedItem?.title ?? "")
            
            self.setup()
        }
    }
    
    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        window?.sheetParent?.endSheet(window!)
    }
}
