import SwiftUI

// MARK: - Main menu items

struct MainMenuItem: Identifiable {
    let id: Int
    let title: String
    let destination: NavigationDestination
}

// MARK: - MainMenuView

struct MainMenuView: View {

    static let itemCount = 4

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var player:   PlayerEngine
    @EnvironmentObject private var library:  LibraryManager

    private var items: [MainMenuItem] {
        [
            MainMenuItem(id: 0, title: "Music",        destination: .musicMenu),
            MainMenuItem(id: 1, title: "Settings",     destination: .settings),
            MainMenuItem(id: 2, title: "Shuffle Songs",destination: .nowPlaying),
            MainMenuItem(id: 3, title: "Now Playing",  destination: .nowPlaying),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: "iPod",
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        ListRowView(
                            text: item.title,
                            isSelected: appState.selectedIndex == index
                        )
                        .onTapGesture {
                            appState.selectedIndex = index
                            navigateTo(item)
                        }

                        if index < items.count - 1 {
                            Divider().padding(.leading, 8)
                        }
                    }
                }
            }
            .background(bgColor)
        }
    }

    private func navigateTo(_ item: MainMenuItem) {
        switch item.destination {
        case .nowPlaying where item.title == "Shuffle Songs":
            let all = library.sortedTracks
            guard !all.isEmpty else { return }
            var shuffled = all
            shuffled.shuffle()
            player.loadQueue(shuffled, startAt: 0)
            appState.push(.nowPlaying)
        default:
            appState.push(item.destination)
        }
    }

    private var bgColor: Color {
        appState.appTheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xDDE5ED)
    }
}
