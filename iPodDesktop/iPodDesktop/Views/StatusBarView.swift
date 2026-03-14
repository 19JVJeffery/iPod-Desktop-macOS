import SwiftUI
import IOKit.ps

// MARK: - StatusBarView

/// The horizontal bar at the top of the iPod screen showing the screen title,
/// a small playback icon and the macOS battery / time information.
struct StatusBarView: View {
    let title: String
    let isPlaying: Bool
    let colorScheme: iPodColorScheme

    var body: some View {
        ZStack {
            // Gradient background matching the original Classipod status bar
            LinearGradient(
                colors: [
                    Color(hex: 0xFCFCFC),
                    Color(hex: 0x8A8C8B),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isPlaying ? "play.fill" : "pause.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x70A9DB))

                BatteryIndicatorView()
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 22)
        .overlay(alignment: .bottom) {
            Divider()
                .background(Color(hex: 0x71797B))
        }
    }
}

// MARK: - BatteryIndicatorView

/// A small pill that shows the current system battery level.
private struct BatteryIndicatorView: View {

    @State private var batteryLevel: Float = 1.0
    @State private var isCharging = false

    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                // Outline
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: 0x69696A), lineWidth: 0.8)
                    .frame(width: 18, height: 9)

                // Fill bar
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(fillColor)
                    .frame(width: max(1, 16 * CGFloat(batteryLevel)), height: 7)
                    .padding(.leading, 1)
            }

            // Terminal nub
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: 0x69696A))
                .frame(width: 2, height: 4)
        }
        .onAppear { refreshBattery() }
    }

    private var fillColor: Color {
        batteryLevel > 0.25 ? Color(hex: 0xAFCE92) : Color(hex: 0xBE836F)
    }

    private func refreshBattery() {
        let source = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(source).takeRetainedValue() as [CFTypeRef]
        guard let ps = list.first,
              let info = IOPSGetPowerSourceDescription(source, ps).takeUnretainedValue() as? [String: Any]
        else { batteryLevel = 1.0; return }
        let current = info[kIOPSCurrentCapacityKey] as? Int ?? 100
        let maximum = info[kIOPSMaxCapacityKey]     as? Int ?? 100
        batteryLevel = Float(current) / Float(maximum)
    }
}
