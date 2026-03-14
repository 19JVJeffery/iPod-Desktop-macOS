import SwiftUI

// MARK: - iPodDesktopApp

@main
struct iPodDesktopApp: App {

    // Shared state objects that flow to every view via environment
    @StateObject private var appState = AppState()
    @StateObject private var player   = PlayerEngine()
    @StateObject private var library  = LibraryManager()

    var body: some Scene {
        Window("iPod Desktop", id: "main") {
            ContentView()
                .environmentObject(appState)
                .environmentObject(player)
                .environmentObject(library)
                .preferredColorScheme(appState.appTheme == .dark ? .dark : .light)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 310, height: 648)
        .commands {
            iPodMenuCommands(appState: appState, player: player, library: library)
        }
    }
}

// MARK: - Menu bar commands

struct iPodMenuCommands: Commands {

    let appState: AppState
    let player:   PlayerEngine
    let library:  LibraryManager

    var body: some Commands {
        CommandGroup(replacing: .newItem) { }

        CommandMenu("Playback") {
            Button(player.isPlaying ? "Pause" : "Play") {
                player.togglePlayPause()
            }
            .keyboardShortcut(.space, modifiers: [])

            Divider()

            Button("Next Track") { player.nextTrack() }
                .keyboardShortcut(.rightArrow, modifiers: .command)

            Button("Previous Track") { player.previousTrack() }
                .keyboardShortcut(.leftArrow, modifiers: .command)

            Divider()

            Button("Volume Up") { player.increaseVolume() }
                .keyboardShortcut(.upArrow, modifiers: .command)

            Button("Volume Down") { player.decreaseVolume() }
                .keyboardShortcut(.downArrow, modifiers: .command)
        }

        CommandMenu("Library") {
            Button("Choose Music Folder…") {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                if panel.runModal() == .OK, let url = panel.url {
                    library.scanFolderURL = url
                }
            }
            .keyboardShortcut("o", modifiers: .command)

            Button("Rescan Library") {
                Task { await library.rescan() }
            }
            .keyboardShortcut("r", modifiers: .command)
        }
    }
}
