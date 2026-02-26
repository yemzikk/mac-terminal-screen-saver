import Foundation
import AppKit

// MARK: - Terminal Theme

struct TerminalTheme: Codable, Equatable {
    var name: String
    var backgroundColor: CodableColor
    var textColor: CodableColor
    var dimTextColor: CodableColor
    var promptColor: CodableColor
    var commandColor: CodableColor
    var outputColor: CodableColor
    var borderColor: CodableColor
    var titleBarColor: CodableColor
    var titleTextColor: CodableColor

    static let themes: [TerminalTheme] = [
        .hackGreen,
        .amberCRT,
        .classicWhite,
        .solarizedDark,
        .monokai,
        .dracula,
        .nord,
        .bluePulse,
    ]

    static let hackGreen = TerminalTheme(
        name: "Hack Green",
        backgroundColor: CodableColor(r: 0.02, g: 0.07, b: 0.02),
        textColor: CodableColor(r: 0.0, g: 1.0, b: 0.0),
        dimTextColor: CodableColor(r: 0.0, g: 0.5, b: 0.0),
        promptColor: CodableColor(r: 0.0, g: 0.8, b: 0.4),
        commandColor: CodableColor(r: 0.2, g: 1.0, b: 0.2),
        outputColor: CodableColor(r: 0.0, g: 0.85, b: 0.0),
        borderColor: CodableColor(r: 0.0, g: 0.4, b: 0.0),
        titleBarColor: CodableColor(r: 0.0, g: 0.15, b: 0.0),
        titleTextColor: CodableColor(r: 0.0, g: 0.9, b: 0.0)
    )

    static let amberCRT = TerminalTheme(
        name: "Amber CRT",
        backgroundColor: CodableColor(r: 0.07, g: 0.04, b: 0.0),
        textColor: CodableColor(r: 1.0, g: 0.65, b: 0.0),
        dimTextColor: CodableColor(r: 0.6, g: 0.38, b: 0.0),
        promptColor: CodableColor(r: 1.0, g: 0.8, b: 0.0),
        commandColor: CodableColor(r: 1.0, g: 0.75, b: 0.1),
        outputColor: CodableColor(r: 0.9, g: 0.6, b: 0.0),
        borderColor: CodableColor(r: 0.5, g: 0.3, b: 0.0),
        titleBarColor: CodableColor(r: 0.12, g: 0.07, b: 0.0),
        titleTextColor: CodableColor(r: 1.0, g: 0.7, b: 0.0)
    )

    static let classicWhite = TerminalTheme(
        name: "Classic White",
        backgroundColor: CodableColor(r: 0.05, g: 0.05, b: 0.08),
        textColor: CodableColor(r: 0.9, g: 0.9, b: 0.9),
        dimTextColor: CodableColor(r: 0.5, g: 0.5, b: 0.5),
        promptColor: CodableColor(r: 0.6, g: 0.8, b: 1.0),
        commandColor: CodableColor(r: 1.0, g: 1.0, b: 1.0),
        outputColor: CodableColor(r: 0.8, g: 0.8, b: 0.8),
        borderColor: CodableColor(r: 0.25, g: 0.25, b: 0.3),
        titleBarColor: CodableColor(r: 0.12, g: 0.12, b: 0.15),
        titleTextColor: CodableColor(r: 0.85, g: 0.85, b: 0.9)
    )

    static let solarizedDark = TerminalTheme(
        name: "Solarized Dark",
        backgroundColor: CodableColor(r: 0.0, g: 0.168, b: 0.211),
        textColor: CodableColor(r: 0.514, g: 0.58, b: 0.588),
        dimTextColor: CodableColor(r: 0.345, g: 0.431, b: 0.459),
        promptColor: CodableColor(r: 0.149, g: 0.545, b: 0.824),
        commandColor: CodableColor(r: 0.576, g: 0.631, b: 0.0),
        outputColor: CodableColor(r: 0.514, g: 0.58, b: 0.588),
        borderColor: CodableColor(r: 0.027, g: 0.212, b: 0.259),
        titleBarColor: CodableColor(r: 0.0, g: 0.137, b: 0.176),
        titleTextColor: CodableColor(r: 0.396, g: 0.482, b: 0.514)
    )

    static let monokai = TerminalTheme(
        name: "Monokai",
        backgroundColor: CodableColor(r: 0.157, g: 0.157, b: 0.157),
        textColor: CodableColor(r: 0.973, g: 0.973, b: 0.949),
        dimTextColor: CodableColor(r: 0.6, g: 0.6, b: 0.6),
        promptColor: CodableColor(r: 0.98, g: 0.149, b: 0.447),
        commandColor: CodableColor(r: 0.663, g: 0.855, b: 0.196),
        outputColor: CodableColor(r: 0.973, g: 0.973, b: 0.949),
        borderColor: CodableColor(r: 0.25, g: 0.25, b: 0.25),
        titleBarColor: CodableColor(r: 0.11, g: 0.11, b: 0.11),
        titleTextColor: CodableColor(r: 0.973, g: 0.973, b: 0.949)
    )

    static let dracula = TerminalTheme(
        name: "Dracula",
        backgroundColor: CodableColor(r: 0.157, g: 0.165, b: 0.212),
        textColor: CodableColor(r: 0.973, g: 0.973, b: 0.949),
        dimTextColor: CodableColor(r: 0.439, g: 0.455, b: 0.573),
        promptColor: CodableColor(r: 0.741, g: 0.576, b: 0.976),
        commandColor: CodableColor(r: 0.314, g: 0.98, b: 0.482),
        outputColor: CodableColor(r: 0.973, g: 0.973, b: 0.949),
        borderColor: CodableColor(r: 0.267, g: 0.278, b: 0.353),
        titleBarColor: CodableColor(r: 0.11, g: 0.118, b: 0.161),
        titleTextColor: CodableColor(r: 0.741, g: 0.576, b: 0.976)
    )

    static let nord = TerminalTheme(
        name: "Nord",
        backgroundColor: CodableColor(r: 0.18, g: 0.204, b: 0.251),
        textColor: CodableColor(r: 0.847, g: 0.871, b: 0.914),
        dimTextColor: CodableColor(r: 0.561, g: 0.604, b: 0.678),
        promptColor: CodableColor(r: 0.506, g: 0.631, b: 0.757),
        commandColor: CodableColor(r: 0.533, g: 0.753, b: 0.816),
        outputColor: CodableColor(r: 0.796, g: 0.839, b: 0.886),
        borderColor: CodableColor(r: 0.231, g: 0.259, b: 0.322),
        titleBarColor: CodableColor(r: 0.145, g: 0.165, b: 0.208),
        titleTextColor: CodableColor(r: 0.506, g: 0.631, b: 0.757)
    )

    static let bluePulse = TerminalTheme(
        name: "Blue Pulse",
        backgroundColor: CodableColor(r: 0.0, g: 0.02, b: 0.08),
        textColor: CodableColor(r: 0.2, g: 0.7, b: 1.0),
        dimTextColor: CodableColor(r: 0.1, g: 0.35, b: 0.6),
        promptColor: CodableColor(r: 0.4, g: 0.9, b: 1.0),
        commandColor: CodableColor(r: 0.3, g: 0.85, b: 1.0),
        outputColor: CodableColor(r: 0.15, g: 0.6, b: 0.9),
        borderColor: CodableColor(r: 0.05, g: 0.2, b: 0.45),
        titleBarColor: CodableColor(r: 0.0, g: 0.04, b: 0.14),
        titleTextColor: CodableColor(r: 0.3, g: 0.75, b: 1.0)
    )
}

// MARK: - Codable Color

struct CodableColor: Codable, Equatable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }

    init(_ color: NSColor) {
        guard let rgb = color.usingColorSpace(.genericRGB) else {
            self.init(r: 1, g: 1, b: 1)
            return
        }
        self.init(r: Double(rgb.redComponent),
                  g: Double(rgb.greenComponent),
                  b: Double(rgb.blueComponent),
                  a: Double(rgb.alphaComponent))
    }

    var nsColor: NSColor {
        NSColor(calibratedRed: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

// MARK: - Settings

class Settings {
    static let shared = Settings()
    private let defaults: UserDefaults

    // Defaults module name used to namespace our keys
    private static let suiteName = "com.terminalscreensaver.prefs"

    // Keys
    private enum Key: String {
        case terminalCount
        case selectedThemeIndex
        case fontSize
        case typingSpeed
        case commandPauseMin
        case commandPauseMax
        case showTitleBar
        case showScanlines
        case showGlow
        case showCursor
        case cornerRadius
        case terminalOpacity
        case showWindowShadow
        case randomizeThemes
    }

    private init() {
        defaults = UserDefaults(suiteName: Self.suiteName) ?? .standard
    }

    // MARK: - Properties

    var terminalCount: Int {
        get { max(1, min(8, defaults.object(forKey: Key.terminalCount.rawValue) as? Int ?? 4)) }
        set { defaults.set(newValue, forKey: Key.terminalCount.rawValue) }
    }

    var selectedThemeIndex: Int {
        get { defaults.object(forKey: Key.selectedThemeIndex.rawValue) as? Int ?? 0 }
        set { defaults.set(newValue, forKey: Key.selectedThemeIndex.rawValue) }
    }

    var currentTheme: TerminalTheme {
        let themes = TerminalTheme.themes
        let idx = selectedThemeIndex
        return idx >= 0 && idx < themes.count ? themes[idx] : themes[0]
    }

    var fontSize: CGFloat {
        get { CGFloat(defaults.object(forKey: Key.fontSize.rawValue) as? Double ?? 11.0) }
        set { defaults.set(Double(newValue), forKey: Key.fontSize.rawValue) }
    }

    /// Characters per second
    var typingSpeed: Double {
        get { defaults.object(forKey: Key.typingSpeed.rawValue) as? Double ?? 40.0 }
        set { defaults.set(newValue, forKey: Key.typingSpeed.rawValue) }
    }

    var commandPauseMin: Double {
        get { defaults.object(forKey: Key.commandPauseMin.rawValue) as? Double ?? 1.5 }
        set { defaults.set(newValue, forKey: Key.commandPauseMin.rawValue) }
    }

    var commandPauseMax: Double {
        get { defaults.object(forKey: Key.commandPauseMax.rawValue) as? Double ?? 4.0 }
        set { defaults.set(newValue, forKey: Key.commandPauseMax.rawValue) }
    }

    var showTitleBar: Bool {
        get { defaults.object(forKey: Key.showTitleBar.rawValue) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.showTitleBar.rawValue) }
    }

    var showScanlines: Bool {
        get { defaults.object(forKey: Key.showScanlines.rawValue) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.showScanlines.rawValue) }
    }

    var showGlow: Bool {
        get { defaults.object(forKey: Key.showGlow.rawValue) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.showGlow.rawValue) }
    }

    var showCursor: Bool {
        get { defaults.object(forKey: Key.showCursor.rawValue) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.showCursor.rawValue) }
    }

    var cornerRadius: CGFloat {
        get { CGFloat(defaults.object(forKey: Key.cornerRadius.rawValue) as? Double ?? 8.0) }
        set { defaults.set(Double(newValue), forKey: Key.cornerRadius.rawValue) }
    }

    var terminalOpacity: Double {
        get { defaults.object(forKey: Key.terminalOpacity.rawValue) as? Double ?? 0.92 }
        set { defaults.set(newValue, forKey: Key.terminalOpacity.rawValue) }
    }

    var showWindowShadow: Bool {
        get { defaults.object(forKey: Key.showWindowShadow.rawValue) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.showWindowShadow.rawValue) }
    }

    var randomizeThemes: Bool {
        get { defaults.object(forKey: Key.randomizeThemes.rawValue) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Key.randomizeThemes.rawValue) }
    }

    func sync() {
        defaults.synchronize()
    }
}
