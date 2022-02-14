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
//        ClockView.shared = self
    }
    
    // MARK: - Configuration
    
    var hasSetup = false
    
    var fontSize: CGFloat = 0
    var vOffset: CGFloat = 0
    
    var backgroundColor: NSColor = .blue
    var foregroundColor: NSColor = .green
    
    var dateFormatter: DateFormatter = DateFormatter()
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    var lastUsedNightTimeMode: Bool = false
    
    func setup(force: Bool = false) {
        // Get the current hour to determine conditions for night mode
        let currentHour = Calendar.current.component(.hour, from: Date())
        let useNightTimeMode = preferences.nightTimeMode && (currentHour >= (10 + 12) || currentHour < 6)
        let nightTimeModeChanged = lastUsedNightTimeMode != useNightTimeMode
        
        // Don't run the setup for every frame, only for the first time or when explicitly asked to
        // or when the night time mode changed
        if hasSetup && !force && !nightTimeModeChanged { return }
        hasSetup = true
        
        // Set the background and foreground color variables to use later
        if useNightTimeMode {
            backgroundColor = .black
            // Red night time mode color, picked from the original
            foregroundColor = NSColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)
        } else if preferences.darkTheme {
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
        
        // The font gets a font size relative to the screen width as not to clip.
        // I don't know how to determine this correctly, these are ugly hard coded
        // numbers and they MIGHT fail for long strings (bold + AM/PM). If you know
        // of a better system please make a pull request or write me an email!
        // >>> contact.kamik423@gmail.com <<<
        let fontSizeScaleFactor : CGFloat
        switch preferences.fontFamily {
        case .sanFrancisco, .neueHelvetica:
            fontSizeScaleFactor = 0.20
        case .sanFranciscoMono:
            fontSizeScaleFactor = 0.13
        case .newYork:
            fontSizeScaleFactor = 0.17
        }
        fontSize = fontSizeScaleFactor * bounds.width
        
        // Vertical offset of the font. This is manually determined.
        // The 0.15 is to move it down a bit since the center of the font rect is
        // lower than the center of the numbers as the rect accounts for lower case
        // letter that might extend below the baseline.
        //
        // 0.5: align center of target rect with center of screen
        // 0.15: offset so font is visually centered
        vOffset = fontSize * 0.5 - 0.15 * fontSize
        
        // Load the correct font
        let font = preferences.nsFont(ofSize: fontSize)
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
        let targetRect = NSRect(x: 0, y: bounds.height * 0.5 - vOffset, width: bounds.width, height: fontSize)
        
        ///// For debugging the font rect can be drawn now.
        // NSColor.blue.setFill()
        // targetRect.fill()
        
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
