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
        super.init(frame: frame, isPreview: isPreview)
        ClockView.shared = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ClockView.shared = self
    }
    
    // MARK: - Configuration
    
    var hasSetup = false
    
    var fontSize: CGFloat = 0
    var vOffset: CGFloat = 0
    
    var backgroundColor: NSColor = .blue
    var foregroundColor: NSColor = .blue
    
    var dateFormatter: DateFormatter = DateFormatter()
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    func setup(force: Bool = false) {
        if force || !hasSetup {
            hasSetup = true
            
            let currentHour = Calendar.current.component(.hour, from: Date())
            let useNightTimeMode = preferences.nightTimeMode && (currentHour >= (10 + 12) || currentHour < 6)
            
            if preferences.darkTheme {
                backgroundColor = .black
                foregroundColor = useNightTimeMode ? NSColor(red: 2.0 / 3.0, green: 0, blue: 0, alpha: 1) : .white
            } else {
                backgroundColor = .white
                foregroundColor = useNightTimeMode ? .red : .black
            }
            
            let separator = preferences.showTimeSeparators ? ":" : " "
            
            let hour = preferences.useAmPm ? "h" : "HH"
            let minute = "\(separator)mm"
            let second = preferences.showSeconds ? "\(separator)ss" : ""
            let suffix = preferences.useAmPm ? " a" : ""
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "\(hour)\(minute)\(second)\(suffix)"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            fontSize = 0.2 * bounds.width
            
            // TODO: dynamically determine value. I don't know how though
            // 0.5: align center of target rect with center of screen
            // 0.15: offset so font is visually centered
            vOffset = fontSize * 0.5 - 0.15 * fontSize
            
            let font: NSFont
            if preferences.useSystemFont {
                font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: preferences.fontWeight)
            } else {
                let fontName: String
                switch preferences.fontWeight {
                case .ultraLight:   fontName = "Helvetica Neue UltraLight"
                case .thin:         fontName = "Helvetica Neue Thin"
                case .light:        fontName = "Helvetica Neue Light"
                case .regular:      fontName = "Helvetica Neue"
                case .medium:       fontName = "Helvetica Neue Medium"
                case .bold:         fontName = "Helvetica Neue Bold"
                default:            fontName = "Helvetica Neue"
                }
                // not supported:
                // semibold, heavy, black
                font = NSFont(name: fontName, size: fontSize)!
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            attributes = [
                .font : font,
                .foregroundColor: foregroundColor,
                .paragraphStyle: paragraphStyle,
            ]
        }
    }
    
    // MARK: - Drawing
    
    override func animateOneFrame() {
        super.animateOneFrame()
        setNeedsDisplay(bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        setup()
        
        backgroundColor.setFill()
        bounds.fill()
        
        let targetRect = NSRect(x: 0, y: bounds.height * 0.5 - vOffset, width: bounds.width, height: fontSize)
        
//        NSColor.red.setFill()
//        targetRect.fill()
        
        let time = NSString(string: dateFormatter.string(from: Date()))
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
