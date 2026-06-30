import AppKit
import Foundation

// A plain NSView whose coordinate system has y=0 at the top (like UIKit / web).
// Used as the NSScrollView document view so the scroll position naturally starts
// at the top of the content without needing a manual scroll-to-top call.
private final class FlippedView: NSView {
    override var isFlipped: Bool { true }
}

// MARK: - ConfigSheetController

class ConfigSheetController: NSWindowController {

    var onDismiss: (() -> Void)?

    // MARK: - UI References
    private var terminalCountStepper: NSStepper!
    private var terminalCountLabel: NSTextField!
    private var themePopup: NSPopUpButton!
    private var randomThemesCheck: NSButton!
    private var fontSizeSlider: NSSlider!
    private var fontSizeLabel: NSTextField!
    private var typingSpeedSlider: NSSlider!
    private var typingSpeedLabel: NSTextField!
    private var showTitleBarCheck: NSButton!
    private var showScanlinesCheck: NSButton!
    private var showGlowCheck: NSButton!
    private var showCursorCheck: NSButton!
    private var showShadowCheck: NSButton!
    private var opacitySlider: NSSlider!
    private var opacityLabel: NSTextField!
    private var cornerRadiusSlider: NSSlider!
    private var cornerRadiusLabel: NSTextField!
    private var previewBox: NSBox!
    private var miniPreview: TerminalWindowView!

    // MARK: - Init

    convenience init() {
        let win = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 580),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Terminal Screen Saver — Settings"
        win.isMovableByWindowBackground = false
        win.isReleasedWhenClosed = false  // keep alive after sheet close
        self.init(window: win)
        buildUI()
        loadSettings()
    }

    // MARK: - UI Construction

    private func buildUI() {
        guard let contentView = window?.contentView else { return }
        contentView.wantsLayer = true

        let s = Settings.shared
        let panelWidth: CGFloat = 560

        // --- Action buttons pinned to the bottom of the window (outside the scroll area) ---
        let cancelBtn = NSButton(frame: NSRect(x: 20, y: 20, width: 100, height: 30))
        cancelBtn.title = "Cancel"
        cancelBtn.bezelStyle = .rounded
        cancelBtn.target = self
        cancelBtn.action = #selector(cancelClicked)
        contentView.addSubview(cancelBtn)

        let okBtn = NSButton(frame: NSRect(x: 440, y: 20, width: 100, height: 30))
        okBtn.title = "OK"
        okBtn.bezelStyle = .rounded
        okBtn.keyEquivalent = "\r"
        okBtn.target = self
        okBtn.action = #selector(okClicked)
        contentView.addSubview(okBtn)

        // Divider between buttons and the scrollable content above
        let bottomDivider = NSBox(frame: NSRect(x: 0, y: 62, width: panelWidth, height: 1))
        bottomDivider.boxType = .separator
        contentView.addSubview(bottomDivider)

        // --- Scroll view filling the window above the button area ---
        let scrollTop: CGFloat = 63
        let windowH = window?.frame.height ?? 580
        let scrollView = NSScrollView(
            frame: NSRect(x: 0, y: scrollTop, width: panelWidth, height: windowH - scrollTop))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        contentView.addSubview(scrollView)

        // FlippedView as the document view: y=0 is the top, so the scroll view
        // naturally opens at the top of the content without a manual scroll call.
        let docView = FlippedView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: 100))
        scrollView.documentView = docView

        var yOffset: CGFloat = 20

        // ---- SECTION: Appearance ----
        docView.addSubview(sectionLabel("Appearance", y: yOffset))
        yOffset += 26

        // Corner Radius
        let (crRow, _, crSlider, crVal) = sliderRow(
            label: "Corner Radius", y: yOffset, min: 0, max: 20, value: Double(s.cornerRadius),
            unit: "pt",
            action: #selector(cornerRadiusChanged)
        )
        docView.addSubview(crRow)
        cornerRadiusSlider = crSlider
        cornerRadiusLabel = crVal
        yOffset += 32

        // Opacity
        let (opRow, _, opSlider, opVal) = sliderRow(
            label: "Terminal Opacity", y: yOffset, min: 0.5, max: 1.0, value: s.terminalOpacity,
            unit: "%",
            action: #selector(opacityChanged)
        )
        docView.addSubview(opRow)
        opacitySlider = opSlider
        opacityLabel = opVal
        yOffset += 32

        // Checkboxes row 1
        let checksRow1 = NSView(frame: NSRect(x: 20, y: yOffset, width: 520, height: 24))
        showTitleBarCheck = checkbox(
            "Show Title Bar", state: s.showTitleBar, action: #selector(checkChanged))
        showTitleBarCheck.frame = NSRect(x: 0, y: 0, width: 130, height: 24)
        showScanlinesCheck = checkbox(
            "Scanlines", state: s.showScanlines, action: #selector(checkChanged))
        showScanlinesCheck.frame = NSRect(x: 140, y: 0, width: 110, height: 24)
        showGlowCheck = checkbox(
            "Vignette Glow", state: s.showGlow, action: #selector(checkChanged))
        showGlowCheck.frame = NSRect(x: 260, y: 0, width: 130, height: 24)
        showCursorCheck = checkbox(
            "Blinking Cursor", state: s.showCursor, action: #selector(checkChanged))
        showCursorCheck.frame = NSRect(x: 400, y: 0, width: 130, height: 24)
        checksRow1.addSubview(showTitleBarCheck)
        checksRow1.addSubview(showScanlinesCheck)
        checksRow1.addSubview(showGlowCheck)
        checksRow1.addSubview(showCursorCheck)
        docView.addSubview(checksRow1)
        yOffset += 32

        showShadowCheck = checkbox(
            "Window Shadow", state: s.showWindowShadow, action: #selector(checkChanged))
        showShadowCheck.frame = NSRect(x: 20, y: yOffset, width: 140, height: 24)
        docView.addSubview(showShadowCheck)
        yOffset += 36

        let div2 = NSBox(frame: NSRect(x: 20, y: yOffset, width: 520, height: 2))
        div2.boxType = .separator
        docView.addSubview(div2)
        yOffset += 12

        // ---- SECTION: Font & Speed ----
        docView.addSubview(sectionLabel("Font & Animation", y: yOffset))
        yOffset += 26

        // Font size
        let (fsRow, _, fsSlider, fsVal) = sliderRow(
            label: "Font Size", y: yOffset, min: 8, max: 18, value: Double(s.fontSize), unit: "pt",
            action: #selector(fontSizeChanged)
        )
        docView.addSubview(fsRow)
        fontSizeSlider = fsSlider
        fontSizeLabel = fsVal
        yOffset += 32

        // Typing speed
        let (tsRow, _, tsSlider, tsVal) = sliderRow(
            label: "Typing Speed", y: yOffset, min: 5, max: 120, value: s.typingSpeed,
            unit: "ch/s",
            action: #selector(typingSpeedChanged)
        )
        docView.addSubview(tsRow)
        typingSpeedSlider = tsSlider
        typingSpeedLabel = tsVal
        yOffset += 36

        let div3 = NSBox(frame: NSRect(x: 20, y: yOffset, width: 520, height: 2))
        div3.boxType = .separator
        docView.addSubview(div3)
        yOffset += 12

        // ---- SECTION: Theme ----
        docView.addSubview(sectionLabel("Theme & Layout", y: yOffset))
        yOffset += 26

        // Theme selector
        let themeRowLbl = label("Color Theme:", x: 20, y: yOffset + 3)
        docView.addSubview(themeRowLbl)

        themePopup = NSPopUpButton(
            frame: NSRect(x: 130, y: yOffset, width: 200, height: 26), pullsDown: false)
        for theme in TerminalTheme.themes {
            themePopup.addItem(withTitle: theme.name)
        }
        themePopup.selectItem(at: s.selectedThemeIndex)
        themePopup.target = self
        themePopup.action = #selector(themeChanged)
        docView.addSubview(themePopup)

        randomThemesCheck = checkbox(
            "Random Theme Per Window", state: s.randomizeThemes, action: #selector(checkChanged))
        randomThemesCheck.frame = NSRect(x: 345, y: yOffset + 2, width: 200, height: 22)
        docView.addSubview(randomThemesCheck)
        yOffset += 36

        // Terminal count
        let tcLbl = label("Terminals:", x: 20, y: yOffset + 5)
        docView.addSubview(tcLbl)

        terminalCountLabel = valueLabel("\(s.terminalCount)", x: 130, y: yOffset + 4)
        docView.addSubview(terminalCountLabel)

        terminalCountStepper = NSStepper(frame: NSRect(x: 160, y: yOffset, width: 40, height: 28))
        terminalCountStepper.minValue = 1
        terminalCountStepper.maxValue = 8
        terminalCountStepper.intValue = Int32(s.terminalCount)
        terminalCountStepper.increment = 1
        terminalCountStepper.target = self
        terminalCountStepper.action = #selector(countChanged)
        docView.addSubview(terminalCountStepper)

        let countHint = label("(1–8 terminal windows)", x: 210, y: yOffset + 5, size: 11)
        countHint.textColor = .secondaryLabelColor
        docView.addSubview(countHint)
        yOffset += 40

        // Preset layout buttons
        let presetLbl = label("Quick Presets:", x: 20, y: yOffset + 5)
        docView.addSubview(presetLbl)
        let presets = [(1, "1"), (2, "2"), (3, "3"), (4, "4"), (6, "6"), (8, "8")]
        for (i, (count, title)) in presets.enumerated() {
            let btn = NSButton(
                frame: NSRect(x: 130 + CGFloat(i) * 55, y: yOffset, width: 50, height: 26))
            btn.title = title
            btn.bezelStyle = .rounded
            btn.tag = count
            btn.target = self
            btn.action = #selector(presetClicked(_:))
            docView.addSubview(btn)
        }
        yOffset += 44

        let div4 = NSBox(frame: NSRect(x: 20, y: yOffset, width: 520, height: 2))
        div4.boxType = .separator
        docView.addSubview(div4)
        yOffset += 12

        // ---- Mini Preview ----
        docView.addSubview(sectionLabel("Preview", y: yOffset))
        yOffset += 26

        let previewFrame = NSRect(x: 20, y: yOffset, width: 520, height: 120)
        previewBox = NSBox(frame: previewFrame)
        previewBox.boxType = .custom
        previewBox.fillColor = .black
        previewBox.borderColor = .darkGray
        previewBox.cornerRadius = 6
        docView.addSubview(previewBox)

        let miniFrame = NSRect(x: 10, y: 10, width: 500, height: 100)
        miniPreview = TerminalWindowView(frame: miniFrame, theme: Settings.shared.currentTheme)
        previewBox.addSubview(miniPreview)
        miniPreview.startAnimating()

        yOffset += 130 + 20  // preview height + bottom padding

        // Size the document view to its content; the scroll view handles overflow.
        docView.frame = NSRect(x: 0, y: 0, width: panelWidth, height: yOffset)
    }

    // MARK: - UI Factory Helpers

    private func sectionLabel(_ text: String, y: CGFloat) -> NSTextField {
        let lbl = NSTextField(frame: NSRect(x: 20, y: y, width: 520, height: 20))
        lbl.stringValue = text
        lbl.isEditable = false
        lbl.isBordered = false
        lbl.backgroundColor = .clear
        lbl.font = NSFont.boldSystemFont(ofSize: 13)
        lbl.textColor = .labelColor
        return lbl
    }

    private func label(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat = 13) -> NSTextField {
        let lbl = NSTextField(frame: NSRect(x: x, y: y, width: 120, height: 20))
        lbl.stringValue = text
        lbl.isEditable = false
        lbl.isBordered = false
        lbl.backgroundColor = .clear
        lbl.font = NSFont.systemFont(ofSize: size)
        lbl.textColor = .labelColor
        return lbl
    }

    private func valueLabel(_ text: String, x: CGFloat, y: CGFloat) -> NSTextField {
        let lbl = NSTextField(frame: NSRect(x: x, y: y, width: 40, height: 20))
        lbl.stringValue = text
        lbl.isEditable = false
        lbl.isBordered = false
        lbl.backgroundColor = .clear
        lbl.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        lbl.textColor = .labelColor
        return lbl
    }

    private func checkbox(_ title: String, state: Bool, action: Selector) -> NSButton {
        let btn = NSButton(checkboxWithTitle: title, target: self, action: action)
        btn.state = state ? .on : .off
        btn.font = NSFont.systemFont(ofSize: 13)
        return btn
    }

    private func sliderRow(
        label labelText: String,
        y: CGFloat,
        min: Double,
        max: Double,
        value: Double,
        unit: String,
        action: Selector
    ) -> (NSView, NSTextField, NSSlider, NSTextField) {
        let container = NSView(frame: NSRect(x: 20, y: y, width: 520, height: 24))

        let lbl = NSTextField(frame: NSRect(x: 0, y: 2, width: 140, height: 20))
        lbl.stringValue = labelText + ":"
        lbl.isEditable = false
        lbl.isBordered = false
        lbl.backgroundColor = .clear
        lbl.font = NSFont.systemFont(ofSize: 13)
        container.addSubview(lbl)

        let slider = NSSlider(frame: NSRect(x: 145, y: 0, width: 280, height: 24))
        slider.minValue = min
        slider.maxValue = max
        slider.doubleValue = value
        slider.target = self
        slider.action = action
        container.addSubview(slider)

        let displayVal: String
        if unit == "%" {
            displayVal = String(format: "%.0f%%", value * 100)
        } else {
            displayVal = String(format: "%.0f \(unit)", value)
        }
        let valLbl = NSTextField(frame: NSRect(x: 435, y: 2, width: 80, height: 20))
        valLbl.stringValue = displayVal
        valLbl.isEditable = false
        valLbl.isBordered = false
        valLbl.backgroundColor = .clear
        valLbl.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        valLbl.textColor = .secondaryLabelColor
        container.addSubview(valLbl)

        return (container, lbl, slider, valLbl)
    }

    // MARK: - Load / Save

    private func loadSettings() {
        reloadSettings()
    }

    /// Sync all controls from the current saved settings.
    /// Called on first build and whenever the sheet is re-opened.
    func reloadSettings() {
        let s = Settings.shared
        terminalCountStepper.intValue = Int32(s.terminalCount)
        terminalCountLabel.stringValue = "\(s.terminalCount)"
        themePopup.selectItem(at: s.selectedThemeIndex)
        fontSizeSlider.doubleValue = Double(s.fontSize)
        fontSizeLabel.stringValue = String(format: "%.0f pt", s.fontSize)
        typingSpeedSlider.doubleValue = s.typingSpeed
        typingSpeedLabel.stringValue = String(format: "%.0f ch/s", s.typingSpeed)
        opacitySlider.doubleValue = s.terminalOpacity
        opacityLabel.stringValue = String(format: "%.0f%%", s.terminalOpacity * 100)
        cornerRadiusSlider.doubleValue = Double(s.cornerRadius)
        cornerRadiusLabel.stringValue = String(format: "%.0f pt", s.cornerRadius)
        showTitleBarCheck.state = s.showTitleBar ? .on : .off
        showScanlinesCheck.state = s.showScanlines ? .on : .off
        showGlowCheck.state = s.showGlow ? .on : .off
        showCursorCheck.state = s.showCursor ? .on : .off
        showShadowCheck.state = s.showWindowShadow ? .on : .off
        randomThemesCheck.state = s.randomizeThemes ? .on : .off
        miniPreview.theme = s.currentTheme
        miniPreview.setNeedsDisplay(miniPreview.bounds)
    }

    private func saveSettings() {
        let s = Settings.shared
        s.terminalCount = Int(terminalCountStepper.intValue)
        s.selectedThemeIndex = themePopup.indexOfSelectedItem
        s.fontSize = CGFloat(fontSizeSlider.doubleValue)
        s.typingSpeed = typingSpeedSlider.doubleValue
        s.showTitleBar = showTitleBarCheck.state == .on
        s.showScanlines = showScanlinesCheck.state == .on
        s.showGlow = showGlowCheck.state == .on
        s.showCursor = showCursorCheck.state == .on
        s.showWindowShadow = showShadowCheck.state == .on
        s.cornerRadius = CGFloat(cornerRadiusSlider.doubleValue)
        s.terminalOpacity = opacitySlider.doubleValue
        s.randomizeThemes = randomThemesCheck.state == .on
        s.sync()
    }

    // MARK: - Actions

    @objc private func okClicked() {
        saveSettings()
        miniPreview.stopAnimating()
        guard let sheet = window else { return }
        sheet.sheetParent?.endSheet(sheet)
        onDismiss?()
    }

    @objc private func cancelClicked() {
        miniPreview.stopAnimating()
        guard let sheet = window else { return }
        sheet.sheetParent?.endSheet(sheet)
    }

    deinit {
        miniPreview?.stopAnimating()  // tear down preview timers on any dismiss path
    }

    @objc private func countChanged() {
        let v = Int(terminalCountStepper.intValue)
        terminalCountLabel.stringValue = "\(v)"
    }

    @objc private func themeChanged() {
        let idx = themePopup.indexOfSelectedItem
        if idx >= 0 && idx < TerminalTheme.themes.count {
            miniPreview.theme = TerminalTheme.themes[idx]
            miniPreview.setNeedsDisplay(miniPreview.bounds)
        }
    }

    @objc private func fontSizeChanged() {
        let v = fontSizeSlider.doubleValue
        fontSizeLabel.stringValue = String(format: "%.0f pt", v)
    }

    @objc private func typingSpeedChanged() {
        let v = typingSpeedSlider.doubleValue
        typingSpeedLabel.stringValue = String(format: "%.0f ch/s", v)
    }

    @objc private func opacityChanged() {
        let v = opacitySlider.doubleValue
        opacityLabel.stringValue = String(format: "%.0f%%", v * 100)
    }

    @objc private func cornerRadiusChanged() {
        let v = cornerRadiusSlider.doubleValue
        cornerRadiusLabel.stringValue = String(format: "%.0f pt", v)
    }

    @objc private func checkChanged() {
        // nothing extra needed, read on save
    }

    @objc private func presetClicked(_ sender: NSButton) {
        let count = sender.tag
        terminalCountStepper.intValue = Int32(count)
        terminalCountLabel.stringValue = "\(count)"
    }
}
