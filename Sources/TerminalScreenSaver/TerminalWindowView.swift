import AppKit
import Foundation

// MARK: - Cursor State

private enum CursorState {
    case idle
    case typing
    case awaitingOutput
    case showingOutput
    case waiting
}

// MARK: - TerminalLine

private struct TerminalLine {
    enum Kind { case prompt, command, output, blank }
    var text: String
    var kind: Kind
    var isPartial: Bool = false  // currently being typed
}

// MARK: - TerminalWindowView

class TerminalWindowView: NSView {

    // MARK: - Configuration
    var theme: TerminalTheme
    var sessionTitle: String = "bash"
    var settings: Settings { Settings.shared }

    // MARK: - Layout constants (derived dynamically)
    private var titleBarHeight: CGFloat {
        settings.showTitleBar ? max(22, settings.fontSize * 1.8) : 0
    }
    private var padding: CGFloat { settings.fontSize * 1.0 }
    private var lineHeight: CGFloat { settings.fontSize * 1.45 }
    private var font: NSFont {
        NSFont(name: "Menlo", size: settings.fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: settings.fontSize, weight: .regular)
    }

    // MARK: - Animation state
    private var lines: [TerminalLine] = []
    private var commandQueue: [TerminalCommand] = []
    private var session: TerminalSession?
    private var state: CursorState = .idle
    private var cursorVisible: Bool = true
    private var cursorBlinkTimer: Timer?
    private var animationTimer: Timer?
    private var typingIndex: Int = 0  // character index being typed
    private var outputLineIndex: Int = 0
    private var forceRedraw: Bool = false

    // MARK: - Realism effects state
    /// Subtle layer opacity flicker simulating phosphor/CRT power variation
    private var flickerTimer: Timer?
    /// Flicker phase counter — occasionally dips harder for a 'beat'
    private var flickerBeat: Int = 0

    // MARK: - Init

    init(frame: NSRect, theme: TerminalTheme) {
        self.theme = theme
        super.init(frame: frame)
        wantsLayer = true
        setup()
    }

    required init?(coder: NSCoder) {
        self.theme = TerminalTheme.hackGreen
        super.init(coder: coder)
        wantsLayer = true
        setup()
    }

    // MARK: - Setup

    private func setup() {
        startNewSession()
        startCursorBlink()
    }

    func startNewSession() {
        let s = CommandDatabase.randomSession()
        session = s
        sessionTitle = s.title
        commandQueue = s.commands.shuffled().isEmpty ? s.commands : Array(s.commands)
        lines = []
        // Add a few blank startup lines
        lines.append(TerminalLine(text: "", kind: .blank))
        state = .idle
        scheduleNextCommand(delay: Double.random(in: 0.3...1.5))
    }

    // MARK: - Timer Management

    func startAnimating() {
        startCursorBlink()
        startFlicker()
        if state == .idle {
            scheduleNextCommand(delay: 0.5)
        }
    }

    func stopAnimating() {
        cursorBlinkTimer?.invalidate()
        cursorBlinkTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        flickerTimer?.invalidate()
        flickerTimer = nil
    }

    // MARK: - Phosphor Flicker
    private func startFlicker() {
        flickerTimer?.invalidate()
        // Schedule next flicker tick at a random interval — mostly fast, occasionally a longer pause
        let interval = Double.random(in: 0.04...0.22)
        flickerTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) {
            [weak self] _ in
            guard let self = self else { return }
            self.flickerBeat = (self.flickerBeat + 1) % 60
            // Every ~60 beats do a slightly more visible dip (like a CRT cycle beat)
            let isBeat = self.flickerBeat == 0
            let alpha: Float =
                isBeat
                ? Float.random(in: 0.93...0.97)  // deeper dip
                : Float.random(in: 0.97...1.00)  // gentle variation
            self.layer?.opacity = alpha
            self.startFlicker()
        }
    }

    private func startCursorBlink() {
        cursorBlinkTimer?.invalidate()
        cursorBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.53, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            self.cursorVisible.toggle()
            self.setNeedsDisplay(self.bounds)
        }
    }

    private func scheduleNextCommand(delay: Double) {
        animationTimer?.invalidate()
        guard !commandQueue.isEmpty else {
            // All commands done - pause then start new session
            state = .waiting
            animationTimer = Timer.scheduledTimer(
                withTimeInterval: Double.random(in: 2.0...5.0), repeats: false
            ) { [weak self] _ in
                self?.startNewSession()
            }
            return
        }
        state = .idle
        animationTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
            [weak self] _ in
            self?.beginNextCommand()
        }
    }

    private func beginNextCommand() {
        guard !commandQueue.isEmpty else {
            scheduleNextCommand(delay: 1.0)
            return
        }
        let cmd = commandQueue.removeFirst()
        // Add prompt + empty command line
        lines.append(TerminalLine(text: cmd.prompt + " ", kind: .prompt))
        lines.append(TerminalLine(text: "", kind: .command, isPartial: true))
        state = .typing
        typingIndex = 0
        pruneLines()
        setNeedsDisplay(bounds)
        scheduleTyping(command: cmd.command, output: cmd.output)
    }

    private func scheduleTyping(command: String, output: [String]) {
        let charsPerSec = settings.typingSpeed
        let interval = 1.0 / charsPerSec
        // Add random hesitations
        let delays: [TimeInterval] = command.map { _ in
            let base = interval
            let jitter = Double.random(in: -interval * 0.4...interval * 0.4)
            return max(0.01, base + jitter)
        }

        func typeNextChar(at index: Int) {
            guard index < command.count else {
                // done typing - wait then show output
                state = .awaitingOutput
                let pause = Double.random(
                    in: settings.commandPauseMin * 0.3...settings.commandPauseMin)
                animationTimer = Timer.scheduledTimer(withTimeInterval: pause, repeats: false) {
                    [weak self] _ in
                    self?.revealOutput(output)
                }
                return
            }
            let charIndex = command.index(command.startIndex, offsetBy: index)
            let typed = String(command[command.startIndex...charIndex])
            if let lastIdx = lines.indices.last {
                lines[lastIdx].text = typed
                lines[lastIdx].isPartial = true
            }
            setNeedsDisplay(bounds)

            let delay = delays[index]
            animationTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                [weak self] _ in
                guard self != nil else { return }
                typeNextChar(at: index + 1)
            }
        }
        typeNextChar(at: 0)
    }

    private func revealOutput(_ output: [String]) {
        guard !output.isEmpty else {
            // Mark command line as done
            if let lastCmdIdx = lines.indices.last(where: { lines[$0].kind == .command }) {
                lines[lastCmdIdx].isPartial = false
            }
            scheduleNextCommand(
                delay: Double.random(in: settings.commandPauseMin...settings.commandPauseMax))
            return
        }
        // Mark command line as done
        if let lastCmdIdx = lines.indices.last(where: { lines[$0].kind == .command }) {
            lines[lastCmdIdx].isPartial = false
        }
        state = .showingOutput
        outputLineIndex = 0

        func addNextOutputLine() {
            guard outputLineIndex < output.count else {
                lines.append(TerminalLine(text: "", kind: .blank))
                pruneLines()
                setNeedsDisplay(bounds)
                scheduleNextCommand(
                    delay: Double.random(in: settings.commandPauseMin...settings.commandPauseMax))
                return
            }
            let line = output[outputLineIndex]
            // Strip ANSI codes for display
            let stripped = stripANSI(line)
            lines.append(TerminalLine(text: stripped, kind: .output))
            outputLineIndex += 1
            pruneLines()
            setNeedsDisplay(bounds)

            let delay = Double.random(in: 0.015...0.08)
            animationTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                [weak self] _ in
                guard self != nil else { return }
                addNextOutputLine()
            }
        }
        addNextOutputLine()
    }

    // MARK: - Line Management

    private func pruneLines() {
        let maxLines = Int((bounds.height - titleBarHeight - padding * 2) / lineHeight) + 5
        if lines.count > maxLines {
            lines.removeFirst(lines.count - maxLines)
        }
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        let s = settings
        let radius = s.cornerRadius

        // --- Window border / shadow painting ---
        let windowRect = bounds

        // Shadow (simple outer glow simulation)
        if s.showWindowShadow {
            ctx.saveGState()
            let shadowColor = theme.textColor.nsColor.withAlphaComponent(0.15).cgColor
            ctx.setShadow(offset: CGSize(width: 0, height: -3), blur: 12, color: shadowColor)
            let path = CGPath(
                roundedRect: windowRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
            ctx.addPath(path)
            ctx.setFillColor(theme.backgroundColor.nsColor.withAlphaComponent(0).cgColor)
            ctx.fillPath()
            ctx.restoreGState()
        }

        // Background fill
        let bgPath = CGPath(
            roundedRect: windowRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
        ctx.saveGState()
        ctx.addPath(bgPath)
        ctx.clip()
        ctx.setFillColor(
            theme.backgroundColor.nsColor.withAlphaComponent(CGFloat(s.terminalOpacity)).cgColor)
        ctx.fill(windowRect)

        // Title bar
        if s.showTitleBar {
            let titleRect = CGRect(
                x: 0, y: windowRect.height - titleBarHeight, width: windowRect.width,
                height: titleBarHeight)
            ctx.setFillColor(theme.titleBarColor.nsColor.cgColor)
            ctx.fill(titleRect)

            // Traffic light buttons
            let btnY = titleRect.midY
            let btnRadius: CGFloat = min(5.5, s.fontSize * 0.5)
            let colors: [CGColor] = [
                NSColor(red: 0.98, green: 0.37, blue: 0.35, alpha: 1).cgColor,
                NSColor(red: 0.98, green: 0.74, blue: 0.25, alpha: 1).cgColor,
                NSColor(red: 0.19, green: 0.78, blue: 0.35, alpha: 1).cgColor,
            ]
            for (i, color) in colors.enumerated() {
                let x: CGFloat = 12 + CGFloat(i) * (btnRadius * 2 + 5)
                ctx.setFillColor(color)
                ctx.fillEllipse(
                    in: CGRect(
                        x: x - btnRadius, y: btnY - btnRadius, width: btnRadius * 2,
                        height: btnRadius * 2))
            }

            // Title text
            let titleFont =
                NSFont(name: "Menlo", size: min(s.fontSize * 0.9, 13))
                ?? NSFont.systemFont(ofSize: 12)
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: theme.titleTextColor.nsColor,
            ]
            let titleStr = NSAttributedString(string: sessionTitle, attributes: titleAttrs)
            let titleSize = titleStr.size()
            let titleX = (windowRect.width - titleSize.width) / 2
            let titleY = titleRect.midY - titleSize.height / 2
            titleStr.draw(at: CGPoint(x: titleX, y: titleY))

            // Title bar separator line
            ctx.setStrokeColor(theme.borderColor.nsColor.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: 0, y: titleRect.minY))
            ctx.addLine(to: CGPoint(x: windowRect.width, y: titleRect.minY))
            ctx.strokePath()
        }

        // ---- Terminal content area ----
        let contentRect = CGRect(
            x: 0, y: 0, width: windowRect.width, height: windowRect.height - titleBarHeight)
        ctx.clip(to: contentRect)

        // Draw lines from bottom up
        let font = self.font
        let fSize = s.fontSize

        let renderLines = lines

        // How many lines fit
        let usableHeight = contentRect.height - padding * 2
        let maxVisible = Int(usableHeight / lineHeight)
        let startIdx = max(0, renderLines.count - maxVisible)
        let visibleLines = Array(renderLines[startIdx...])

        for (i, line) in visibleLines.enumerated() {
            let y = contentRect.height - padding - CGFloat(i + 1) * lineHeight
            guard y > -lineHeight else { break }

            let isCurrent = i == visibleLines.count - 1

            switch line.kind {
            case .prompt:
                let parts = line.text.split(separator: "$", maxSplits: 1)
                if parts.count == 2 {
                    let promptPart = String(parts[0]) + "$"
                    let rest = String(parts[1])
                    drawText(
                        promptPart, at: CGPoint(x: padding, y: y), color: theme.promptColor.nsColor,
                        font: font)
                    let promptWidth = textWidth(promptPart, font: font)
                    drawText(
                        rest, at: CGPoint(x: padding + promptWidth, y: y),
                        color: theme.textColor.nsColor, font: font)
                } else {
                    drawText(
                        line.text, at: CGPoint(x: padding, y: y), color: theme.promptColor.nsColor,
                        font: font)
                }

            case .command:
                // Find the corresponding prompt to get its width
                let promptLine = visibleLines[max(0, i - 1)]
                var promptWidth: CGFloat = 0
                if promptLine.kind == .prompt {
                    promptWidth = textWidth(promptLine.text, font: font)
                }
                drawText(
                    line.text, at: CGPoint(x: padding + promptWidth, y: y),
                    color: theme.commandColor.nsColor, font: font)

                // Draw cursor after last char if typing
                if isCurrent && cursorVisible && s.showCursor {
                    let tw = textWidth(line.text, font: font)
                    let cursorX = padding + promptWidth + tw
                    let cursorRect = CGRect(
                        x: cursorX, y: y - 1, width: fSize * 0.6, height: fSize + 2)
                    ctx.setFillColor(theme.textColor.nsColor.withAlphaComponent(0.85).cgColor)
                    ctx.fill(cursorRect)
                }

            case .output:
                drawText(
                    line.text, at: CGPoint(x: padding, y: y), color: theme.outputColor.nsColor,
                    font: font)

            case .blank:
                break
            }
        }

        // Idle cursor (when no typing is happening)
        if (state == .idle || state == .waiting) && cursorVisible && s.showCursor {
            if let lastLine = visibleLines.last {
                let lastIdx = visibleLines.count - 1
                let y = contentRect.height - padding - CGFloat(lastIdx + 1) * lineHeight
                let tw = textWidth(lastLine.text, font: font) + padding
                let cursorRect = CGRect(x: tw, y: y - 1, width: fSize * 0.6, height: fSize + 2)
                ctx.setFillColor(theme.textColor.nsColor.withAlphaComponent(0.6).cgColor)
                ctx.fill(cursorRect)
            }
        }

        // Scanlines overlay
        if s.showScanlines {
            drawScanlines(ctx: ctx, rect: contentRect)
        }

        // Pixel noise — tiny random phosphor dots scattered across the screen
        drawNoise(ctx: ctx, rect: contentRect)

        // Inner screen edge — faint bright line at the top of the content area
        drawInnerEdge(ctx: ctx, rect: contentRect)

        // Glow/vignette
        if s.showGlow {
            drawVignette(ctx: ctx, rect: windowRect)
        }

        ctx.restoreGState()

        // Window border
        ctx.saveGState()
        let borderPath = CGPath(
            roundedRect: windowRect.insetBy(dx: 0.5, dy: 0.5), cornerWidth: radius,
            cornerHeight: radius, transform: nil)
        ctx.addPath(borderPath)
        ctx.setStrokeColor(theme.borderColor.nsColor.cgColor)
        ctx.setLineWidth(1.0)
        ctx.strokePath()
        ctx.restoreGState()
    }

    // MARK: - Drawing Helpers

    private func drawText(_ text: String, at point: CGPoint, color: NSColor, font: NSFont) {
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
        ]
        // Phosphor glow — soft halo around text when glow is enabled
        if settings.showGlow {
            let glow = NSShadow()
            glow.shadowColor = color.withAlphaComponent(0.55)
            glow.shadowBlurRadius = settings.fontSize * 0.55
            glow.shadowOffset = .zero
            attrs[.shadow] = glow
        }
        NSAttributedString(string: text, attributes: attrs).draw(at: point)
    }

    private func textWidth(_ text: String, font: NSFont) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        return (text as NSString).size(withAttributes: attrs).width
    }

    private func drawScanlines(ctx: CGContext, rect: CGRect) {
        ctx.saveGState()
        var y = rect.minY
        let yInt = Int(rect.minY)
        while y < rect.maxY {
            // Every ~32px a slightly visible horizontal band, like a CRT refresh beat
            let isBand = ((Int(y) - yInt) / 2) % 16 == 0
            let alpha: CGFloat = isBand ? 0.10 : 0.055
            ctx.setFillColor(NSColor.black.withAlphaComponent(alpha).cgColor)
            ctx.fill(CGRect(x: rect.minX, y: y, width: rect.width, height: 1))
            y += 2
        }
        ctx.restoreGState()
    }

    /// Sparse random phosphor noise — gives screen a slightly 'alive' texture
    private func drawNoise(ctx: CGContext, rect: CGRect) {
        ctx.saveGState()
        let dotCount = Int(rect.width * rect.height / 1800)  // scales with window size
        let baseColor = theme.textColor.nsColor
        for _ in 0..<dotCount {
            let x = rect.minX + CGFloat.random(in: 0..<rect.width)
            let y = rect.minY + CGFloat.random(in: 0..<rect.height)
            let alpha = CGFloat.random(in: 0.008...0.055)
            ctx.setFillColor(baseColor.withAlphaComponent(alpha).cgColor)
            ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
        ctx.restoreGState()
    }

    /// Faint bright inner edge at the top of the content area — like a CRT screen lip
    private func drawInnerEdge(ctx: CGContext, rect: CGRect) {
        ctx.saveGState()
        // Top edge: thin highlight
        ctx.setFillColor(theme.textColor.nsColor.withAlphaComponent(0.035).cgColor)
        ctx.fill(CGRect(x: rect.minX, y: rect.maxY - 1, width: rect.width, height: 1))
        // Left edge
        ctx.fill(CGRect(x: rect.minX, y: rect.minY, width: 1, height: rect.height))
        ctx.restoreGState()
    }

    private func drawVignette(ctx: CGContext, rect: CGRect) {
        ctx.saveGState()
        let colors =
            [
                NSColor.black.withAlphaComponent(0).cgColor,
                NSColor.black.withAlphaComponent(0.18).cgColor,
            ] as CFArray
        let locations: [CGFloat] = [0.6, 1.0]
        guard
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)
        else {
            ctx.restoreGState()
            return
        }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = max(rect.width, rect.height) * 0.75
        ctx.drawRadialGradient(
            gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius,
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        ctx.restoreGState()
    }

    // MARK: - ANSI Strip

    private func stripANSI(_ str: String) -> String {
        // Remove ESC[ ... m sequences
        var result = ""
        var i = str.startIndex
        while i < str.endIndex {
            if str[i] == "\u{1B}", str.index(after: i) < str.endIndex,
                str[str.index(after: i)] == "["
            {
                // skip until 'm' or other letter
                var j = str.index(i, offsetBy: 2)
                while j < str.endIndex && !str[j].isLetter {
                    j = str.index(after: j)
                }
                if j < str.endIndex {
                    j = str.index(after: j)
                }
                i = j
            } else {
                result.append(str[i])
                i = str.index(after: i)
            }
        }
        return result
    }
}
