//
//  ClockView.swift
//  Padbury Clock Revived
//
//  Created by Hans Schülein on 2.2.2021.
//

import Cocoa
import ScreenSaver

final class ClockView: ScreenSaverView {
    lazy var sheetController: ConfigureSheetController = ConfigureSheetController()
    var preferences: Preferences = Preferences()
    
    static var shared: ClockView? = nil
    
    override init?(frame: NSRect, isPreview: Bool) {
        // Setup Window
        super.init(frame: frame, isPreview: isPreview)
        if isPreview { ClockView.shared = self }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Configuration
    
    var hasSetup = false
    
    var fontSize: CGFloat = 0
    var vOffset: CGFloat = 0
    var lineHeight: CGFloat = 0
    
    var backgroundColor: NSColor = .blue
    var foregroundColor: NSColor = .green
    
    var dateFormatter: DateFormatter = DateFormatter()
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    var lastUsedNightTimeMode: Bool = false
    var sytemWasDarkMode: Bool = false
    
    func setup(force: Bool = false) {
        // Get the current hour to determine conditions for night mode
        let currentHour = Calendar.current.component(.hour, from: Date())
        let useNightTimeMode = preferences.nightTimeMode && (currentHour >= (10 + 12) || currentHour < 6)
        let nightTimeModeChanged = lastUsedNightTimeMode != useNightTimeMode
        lastUsedNightTimeMode = useNightTimeMode
        
        // Compute dark mode
        let systemIsDarkMode = effectiveAppearance.bestMatch(from: [.darkAqua, .vibrantDark]) == .darkAqua
        let darkModeChanged = systemIsDarkMode != sytemWasDarkMode
        sytemWasDarkMode = systemIsDarkMode
        
        // Don't run the setup for every frame, only for the first time or when explicitly asked to
        // or when the night time mode conditions or dark mode changed
        if hasSetup && !(force || nightTimeModeChanged || darkModeChanged) { return }
        hasSetup = true
        
        // Set the background and foreground color variables to use later
        if useNightTimeMode {
            backgroundColor = .black
            // Red night time mode color, picked from the original
            foregroundColor = NSColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)
        } else if preferences.appearance == .dark || preferences.appearance == .system && systemIsDarkMode {
            backgroundColor = .black
            foregroundColor = .white
        } else { // light theme
            backgroundColor = .white
            foregroundColor = .black
        }
        
        // Use a space or a colon as separator according to the settings
        let separator = preferences.showTimeSeparators ? ":" : " "
        
        // Time format setup according to the seconds
        let hour = preferences.useAmPm ? "h" : "HH"
        let minute = "\(separator)mm"
        let second = preferences.showSeconds ? "\(separator)ss" : ""
        let suffix = preferences.useAmPm ? " a" : ""
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "\(hour)\(minute)\(second)\(suffix)"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"

        // Compute fontsize to fit screen.
        // Sample string is measured. It is contained in <> to give it some consistent space
        // at the edge of the screen.
        var sizingString = "<11"
        sizingString += preferences.showTimeSeparators ? ":" : " "
        sizingString += "59"
        if preferences.showSeconds {
            sizingString += preferences.showTimeSeparators ? ":" : " "
            sizingString += "59"
            sizingString += preferences.useAmPm ? " AM" : ""
        } else {
            // If no seconds are used and no AM the font size should still be decreased a bit
            // because otherwise it will be very gimongous and not very minimalist
            sizingString += preferences.useAmPm ? " AM" : "X"
        }
        sizingString += ">"
        fontSize = 100 * bounds.width / NSString(string: sizingString).size(withAttributes: [.font: preferences.nsFont(ofSize: 100)]).width

        // Load the correct font
        let font = preferences.nsFont(ofSize: fontSize)
        lineHeight = font.ascender - font.descender - font.leading
        vOffset = (font.descender + font.leading) - 0.5 * font.capHeight
        // Set the paragraph style with the correct font, centering and color.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributes = [
            .font : font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle,
        ]
    }
    
    // MARK: - Drawing
    
    override func animateOneFrame() {
        super.animateOneFrame()
        // Update the screen. This could potentially be improved by only updating
        // the text bit.
        setNeedsDisplay(bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Reload variables if needed
        setup()
        
        // Fill the screen in with the background color in case it was not painted
        // yet and to overwrite the last font printed
        backgroundColor.setFill()
        bounds.fill()
        
        // If the setting is set to only draw on the main screen and this is not
        // the main screen stop here.
        let isMainScreen = self.window?.screen == .main
        if preferences.mainScreenOnly && !isMainScreen { return }
        
        // The font rect. vOffset has been described above
        let targetRect = NSRect(x: 0, y: bounds.height / 2 + vOffset, width: bounds.width, height: lineHeight)
        
        ///// For debugging the font rect can be drawn now.
        // NSColor.blue.setFill()
        // targetRect.fill()
        // NSColor.green.setFill()
        // NSRect(x: 0, y: bounds.height / 2, width: bounds.width, height: 1).fill()
        
        // Get the time string
        let time = NSString(string: dateFormatter.string(from: Date()))
        // Draw the time
        time.draw(in: targetRect, withAttributes: attributes)
    }

    // MARK: - Preferences

    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        return sheetController.window
    }
}
