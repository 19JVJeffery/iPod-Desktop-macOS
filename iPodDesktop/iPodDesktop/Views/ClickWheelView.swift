import SwiftUI

// MARK: - ClickWheelView

/// The circular iPod click wheel.
///
/// Provides five discrete tap zones (Menu top, Fast-Forward right,
/// Play/Pause bottom, Rewind left, and the central Select button) plus a
/// continuous rotation gesture that fires `onRotate` with a signed normalised
/// delta (+1 / –1 per scroll step).
struct ClickWheelView: View {

    // MARK: Callbacks

    var onMenu:       () -> Void = {}
    var onForward:    () -> Void = {}
    var onPlay:       () -> Void = {}
    var onBack:       () -> Void = {}
    var onSelect:     () -> Void = {}
    var onRotate:     (_ delta: Int) -> Void = { _ in }   // +1 = clockwise

    // MARK: State

    @EnvironmentObject private var appState: AppState

    @State private var lastAngle: Angle = .zero
    @State private var accumulatedDelta: Double = 0
    @State private var isDragging = false
    @State private var pressedZone: WheelZone? = nil

    // MARK: Constants

    /// How many degrees of rotation equal one scroll step.
    private let stepDegrees: Double = 18

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let outerR = size / 2
            let innerR = outerR * 0.32      // select button radius
            let midR   = (outerR + innerR) / 2

            ZStack {
                // ── Outer ring ──────────────────────────────────────────────
                outerRing(size: size)

                // ── Wheel zone labels ────────────────────────────────────────
                wheelLabel("MENU", angle: .degrees(-90), radius: midR, highlight: pressedZone == .menu)
                wheelLabel("▶▶", angle: .degrees(0),   radius: midR, highlight: pressedZone == .forward)
                wheelLabel("▮▮", angle: .degrees(90),  radius: midR, highlight: pressedZone == .play)
                wheelLabel("◀◀", angle: .degrees(180), radius: midR, highlight: pressedZone == .back)

                // ── Centre select button ────────────────────────────────────
                selectButton(radius: innerR)
            }
            .gesture(
                DragGesture(minimumDistance: 2, coordinateSpace: .local)
                    .onChanged { value in handleDrag(value, center: center, outerR: outerR, innerR: innerR) }
                    .onEnded   { _ in isDragging = false; lastAngle = .zero; accumulatedDelta = 0 }
            )
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { value in handleTap(at: value.location, center: center, outerR: outerR, innerR: innerR) }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: Sub-views

    @ViewBuilder
    private func outerRing(size: CGFloat) -> some View {
        let scheme = appState.colorScheme

        ZStack {
            // Control ring background
            Circle()
                .fill(scheme.controlBackground)

            // Textured gradient overlay mimicking the inner button gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [scheme.buttonGradientTop, scheme.buttonGradientBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(size * 0.06)

            // Border ring
            Circle()
                .strokeBorder(scheme.controlBorderColor, lineWidth: 1.5)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private func selectButton(radius: CGFloat) -> some View {
        let scheme = appState.colorScheme
        let diameter = radius * 2

        Circle()
            .fill(
                LinearGradient(
                    colors: [scheme.controlBackground.opacity(0.9),
                             scheme.controlBackground],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
            .scaleEffect(pressedZone == .select ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: pressedZone)
            .onTapGesture { triggerHaptic(); onSelect() }
    }

    @ViewBuilder
    private func wheelLabel(
        _ text: String,
        angle: Angle,
        radius: CGFloat,
        highlight: Bool
    ) -> some View {
        let scheme = appState.colorScheme
        Text(text)
            .font(.system(size: radius * 0.18, weight: .semibold, design: .rounded))
            .foregroundColor(highlight ? .white : scheme.buttonIconColor)
            .offset(
                x: cos(angle.radians) * radius,
                y: sin(angle.radians) * radius
            )
    }

    // MARK: Gesture handling

    private func handleDrag(
        _ value: DragGesture.Value,
        center: CGPoint,
        outerR: CGFloat,
        innerR: CGFloat
    ) {
        let loc = value.location
        let dx = loc.x - center.x
        let dy = loc.y - center.y
        let dist = sqrt(dx * dx + dy * dy)

        // Only rotate on the ring region, not the centre button
        guard dist > innerR && dist <= outerR else { return }

        let currentAngle = Angle(radians: atan2(Double(dy), Double(dx)))

        if isDragging {
            var delta = currentAngle.degrees - lastAngle.degrees
            // Wrap-around correction
            if delta > 180  { delta -= 360 }
            if delta < -180 { delta += 360 }
            accumulatedDelta += delta

            let steps = Int(accumulatedDelta / stepDegrees)
            if steps != 0 {
                onRotate(steps)
                accumulatedDelta -= Double(steps) * stepDegrees
                triggerHaptic()
            }
        }

        isDragging = true
        lastAngle  = currentAngle
    }

    private func handleTap(
        at location: CGPoint,
        center: CGPoint,
        outerR: CGFloat,
        innerR: CGFloat
    ) {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let dist = sqrt(dx * dx + dy * dy)

        if dist <= innerR {
            triggerHaptic()
            flashZone(.select)
            onSelect()
            return
        }

        guard dist <= outerR else { return }

        let angle = atan2(Double(dy), Double(dx)) * (180 / .pi)
        // atan2 returns –180 … +180, centre-top is –90°
        let zone: WheelZone
        switch angle {
        case -135 ..< -45:  zone = .menu
        case  -45 ..< 45:   zone = .forward
        case   45 ..< 135:  zone = .play
        default:            zone = .back
        }

        triggerHaptic()
        flashZone(zone)

        switch zone {
        case .menu:    onMenu()
        case .forward: onForward()
        case .play:    onPlay()
        case .back:    onBack()
        case .select:  onSelect()
        }
    }

    private func flashZone(_ zone: WheelZone) {
        pressedZone = zone
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { pressedZone = nil }
    }

    private func triggerHaptic() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            .alignment,
            performanceTime: .default
        )
    }
}

// MARK: - WheelZone

private enum WheelZone { case menu, forward, play, back, select }
