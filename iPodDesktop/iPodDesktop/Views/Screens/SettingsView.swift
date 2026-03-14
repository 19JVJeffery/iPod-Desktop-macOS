import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    static let itemCount = 5

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var library:  LibraryManager
    @EnvironmentObject private var player:   PlayerEngine

    private let rowTitles = ["Device Color", "Theme", "Click Wheel Sound", "Music Folder", "About"]

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: "Settings",
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            ScrollView {
                VStack(spacing: 0) {
                    // ── Device Color ─────────────────────────────────────────
                    settingsRow(index: 0) {
                        HStack {
                            Text("Device Color")
                                .font(.system(size: 12))
                            Spacer()
                            Picker("", selection: $appState.colorScheme) {
                                ForEach(iPodColorScheme.allCases, id: \.self) { scheme in
                                    Text(scheme.displayName).tag(scheme)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .frame(width: 90)
                            .font(.system(size: 11))
                        }
                    }

                    Divider().padding(.leading, 8)

                    // ── App Theme ────────────────────────────────────────────
                    settingsRow(index: 1) {
                        HStack {
                            Text("Theme")
                                .font(.system(size: 12))
                            Spacer()
                            Picker("", selection: $appState.appTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { t in
                                    Text(t.displayName).tag(t)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 90)
                        }
                    }

                    Divider().padding(.leading, 8)

                    // ── Click Wheel Sound ────────────────────────────────────
                    settingsRow(index: 2) {
                        Toggle("Click Wheel Sound", isOn: $appState.clickWheelSoundEnabled)
                            .font(.system(size: 12))
                            .toggleStyle(.switch)
                            .controlSize(.mini)
                    }

                    Divider().padding(.leading, 8)

                    // ── Music Folder ─────────────────────────────────────────
                    settingsRow(index: 3) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Music Folder")
                                    .font(.system(size: 12))
                                if let url = library.scanFolderURL {
                                    Text(url.lastPathComponent)
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button("Choose…") { chooseMusicFolder() }
                                .font(.system(size: 11))
                                .buttonStyle(.borderless)
                        }
                    }

                    Divider().padding(.leading, 8)

                    // ── About ────────────────────────────────────────────────
                    settingsRow(index: 4) {
                        HStack {
                            Text("About iPod Desktop")
                                .font(.system(size: 12))
                            Spacer()
                            Text("v1.0")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .background(bgColor)
        }
    }

    @ViewBuilder
    private func settingsRow<Content: View>(index: Int, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(appState.selectedIndex == index ? selectionBackground : Color.clear)
            .onTapGesture { appState.selectedIndex = index }
    }

    private var selectionBackground: Color {
        Color(hex: 0x5382C9).opacity(0.3)
    }

    private var bgColor: Color {
        appState.appTheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xDDE5ED)
    }

    private func chooseMusicFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Choose your Music folder"
        panel.prompt = "Select"

        if panel.runModal() == .OK, let url = panel.url {
            library.scanFolderURL = url
        }
    }
}
