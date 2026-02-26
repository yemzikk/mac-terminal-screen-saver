import AppKit
import ScreenSaver

// MARK: - TerminalScreenSaverView

public class TerminalScreenSaverView: ScreenSaverView {

    // MARK: - Properties

    private var terminalViews: [TerminalWindowView] = []
    private var configSheet: ConfigSheetController?
    private var backgroundView: NSView?

    // MARK: - Init

    public override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        animationTimeInterval = 1.0 / 30.0  // 30 fps timer (our actual animation is timer-driven per window)
        wantsLayer = true
    }

    // MARK: - Lifecycle

    public override func startAnimation() {
        super.startAnimation()
        buildLayout()
        terminalViews.forEach { $0.startAnimating() }
    }

    public override func stopAnimation() {
        terminalViews.forEach { $0.stopAnimating() }
        super.stopAnimation()
    }

    public override func animateOneFrame() {
        // Individual terminal views handle their own animation timers.
        // This is just a safety redraw tick.
        setNeedsDisplay(bounds)
    }

    public override func draw(_ rect: NSRect) {
        // Draw dark background
        NSColor.black.setFill()
        rect.fill()
    }

    // MARK: - Layout

    // Layout style chosen fresh each startAnimation
    private enum LayoutStyle {
        case tiled  // clean non-overlapping grid
        case cascade  // overlapping windows like a real desktop
        case mixed  // some tiled, one floating on top
    }
    private var layoutStyle: LayoutStyle = .tiled

    private func buildLayout() {
        terminalViews.forEach { $0.removeFromSuperview() }
        terminalViews.removeAll()

        let s = Settings.shared
        let count = s.terminalCount
        let screenRect = bounds

        // Pick layout style randomly (cascade only when count >= 3)
        if count >= 3 && !isPreview {
            let roll = Int.random(in: 0..<3)
            layoutStyle = roll == 0 ? .cascade : (roll == 1 ? .mixed : .tiled)
        } else {
            layoutStyle = .tiled
        }

        let frames = layoutFrames(count: count, in: screenRect)
        let themes = buildThemes(count: count)

        for (i, frame) in frames.enumerated() {
            let tv = TerminalWindowView(frame: frame, theme: themes[i])
            addSubview(tv)
            terminalViews.append(tv)
        }
    }

    private func layoutFrames(count: Int, in rect: NSRect) -> [NSRect] {
        let padding: CGFloat = isPreview ? 4 : 16
        let inner = rect.insetBy(dx: padding, dy: padding)

        switch layoutStyle {
        case .cascade:
            return cascadeLayout(count: count, in: inner, padding: padding)
        case .mixed:
            return mixedLayout(count: count, in: inner, padding: padding)
        case .tiled:
            return tiledLayout(count: count, in: inner, padding: padding)
        }
    }

    // MARK: - Tiled (classic grid)
    private func tiledLayout(count: Int, in rect: NSRect, padding: CGFloat) -> [NSRect] {
        switch count {
        case 1: return [rect]
        case 2: return hSplit(rect, padding: padding)
        case 3: return threeLayout(rect, padding: padding)
        case 4: return grid(rect, cols: 2, rows: 2, padding: padding)
        case 5: return fiveLayout(rect, padding: padding)
        case 6: return grid(rect, cols: 3, rows: 2, padding: padding)
        case 7: return sevenLayout(rect, padding: padding)
        case 8: return grid(rect, cols: 4, rows: 2, padding: padding)
        default: return [rect]
        }
    }

    // MARK: - Cascade layout (windows overlap like a real desktop)
    private func cascadeLayout(count: Int, in rect: NSRect, padding: CGFloat) -> [NSRect] {
        // Smaller windows so you can see most of the content of the window below
        let winW = rect.width * CGFloat.random(in: 0.44...0.54)
        let winH = rect.height * CGFloat.random(in: 0.44...0.54)
        // Large step so each window only covers the title bar + ~25% of the one below
        let stepX: CGFloat = isPreview ? 16 : 80
        let stepY: CGFloat = isPreview ? 16 : 80

        // Total cascade drift must fit within the screen
        let maxCount = CGFloat(count - 1)
        let clampedStepX = min(stepX, (rect.width - winW - padding * 2) / max(maxCount, 1))
        let clampedStepY = min(stepY, (rect.height - winH - padding * 2) / max(maxCount, 1))

        // Start from near top-left with small margin
        let startX = rect.minX + padding
        let startY = rect.maxY - winH - padding

        return (0..<count).map { i in
            let x = startX + CGFloat(i) * clampedStepX
            let y = startY - CGFloat(i) * clampedStepY
            // Slight size variation per window for realism
            let wVariation = CGFloat.random(in: -winW * 0.05...winW * 0.05)
            let hVariation = CGFloat.random(in: -winH * 0.05...winH * 0.05)
            return NSRect(x: x, y: y, width: winW + wVariation, height: winH + hVariation)
        }
    }

    // MARK: - Mixed layout (base tiled + one floating window on top)
    private func mixedLayout(count: Int, in rect: NSRect, padding: CGFloat) -> [NSRect] {
        guard count >= 3 else { return tiledLayout(count: count, in: rect, padding: padding) }

        // Bottom layer: (count-1) tiled windows
        let tiledCount = count - 1
        var frames = tiledLayout(count: tiledCount, in: rect, padding: padding)

        // Floating window: slightly larger, positioned near center with offset
        let fw = rect.width * CGFloat.random(in: 0.38...0.52)
        let fh = rect.height * CGFloat.random(in: 0.42...0.58)
        let fx = rect.minX + (rect.width - fw) * CGFloat.random(in: 0.25...0.65)
        let fy = rect.minY + (rect.height - fh) * CGFloat.random(in: 0.20...0.60)
        frames.append(NSRect(x: fx, y: fy, width: fw, height: fh))
        return frames
    }

    private func hSplit(_ rect: NSRect, padding: CGFloat) -> [NSRect] {
        let w = (rect.width - padding) / 2
        return [
            NSRect(x: rect.minX, y: rect.minY, width: w, height: rect.height),
            NSRect(x: rect.minX + w + padding, y: rect.minY, width: w, height: rect.height),
        ]
    }

    private func splitVertical(_ rect: NSRect, ratio: CGFloat, padding: CGFloat) -> (NSRect, NSRect)
    {
        let topH = rect.height * ratio - padding / 2
        let botH = rect.height - topH - padding
        let top = NSRect(x: rect.minX, y: rect.maxY - topH, width: rect.width, height: topH)
        let bot = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: botH)
        return (top, bot)
    }

    private func grid(_ rect: NSRect, cols: Int, rows: Int, padding: CGFloat) -> [NSRect] {
        let w = (rect.width - CGFloat(cols - 1) * padding) / CGFloat(cols)
        let h = (rect.height - CGFloat(rows - 1) * padding) / CGFloat(rows)
        var frames: [NSRect] = []
        for row in 0..<rows {
            for col in 0..<cols {
                let x = rect.minX + (w + padding) * CGFloat(col)
                let y = rect.maxY - h - (h + padding) * CGFloat(row)
                frames.append(NSRect(x: x, y: y, width: w, height: h))
            }
        }
        return frames
    }

    private func fiveLayout(_ rect: NSRect, padding: CGFloat) -> [NSRect] {
        // Top row: 3 even, bottom row: 2 even
        let topH = rect.height * 0.55
        let botH = rect.height - topH - padding
        let topRect = NSRect(x: rect.minX, y: rect.maxY - topH, width: rect.width, height: topH)
        let botRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: botH)
        return grid(topRect, cols: 3, rows: 1, padding: padding)
            + grid(botRect, cols: 2, rows: 1, padding: padding)
    }

    private func sevenLayout(_ rect: NSRect, padding: CGFloat) -> [NSRect] {
        // Top: 4, Bottom: 3
        let topH = rect.height * 0.5 - padding / 2
        let botH = rect.height - topH - padding
        let topRect = NSRect(x: rect.minX, y: rect.maxY - topH, width: rect.width, height: topH)
        let botRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: botH)
        return grid(topRect, cols: 4, rows: 1, padding: padding)
            + grid(botRect, cols: 3, rows: 1, padding: padding)
    }

    private func threeLayout(_ rect: NSRect, padding: CGFloat) -> [NSRect] {
        // Left: tall, right: split top/bottom
        let lw = rect.width * 0.45
        let rw = rect.width - lw - padding
        let left = NSRect(x: rect.minX, y: rect.minY, width: lw, height: rect.height)
        let rh = (rect.height - padding) / 2
        let rightTop = NSRect(
            x: rect.minX + lw + padding, y: rect.minY + rh + padding, width: rw, height: rh)
        let rightBot = NSRect(x: rect.minX + lw + padding, y: rect.minY, width: rw, height: rh)
        return [left, rightTop, rightBot]
    }

    private func buildThemes(count: Int) -> [TerminalTheme] {
        let s = Settings.shared
        if s.randomizeThemes {
            let themes = TerminalTheme.themes
            return (0..<count).map { _ in themes.randomElement()! }
        } else {
            return (0..<count).map { _ in s.currentTheme }
        }
    }

    // MARK: - Configuration Sheet

    public override var hasConfigureSheet: Bool { true }

    public override var configureSheet: NSWindow? {
        // Always create a fresh controller (and thus a fresh NSPanel) so we never
        // try to re-present a window that macOS is still animating away from a
        // previous dismissal.  Storing the controller in `configSheet` keeps it
        // alive for the duration of the presentation; the previous controller is
        // released as soon as it is replaced here.
        let ctrl = ConfigSheetController()
        ctrl.onDismiss = { [weak self] in
            self?.buildLayout()
            self?.terminalViews.forEach { $0.startAnimating() }
        }
        configSheet = ctrl
        return ctrl.window
    }
}
