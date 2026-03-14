import SwiftUI

// MARK: - MusicMenuView

struct MusicMenuView: View {

    static let itemCount = 7

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var player:   PlayerEngine

    private struct MenuItem: Identifiable {
        let id: Int
        let title: String
        let destination: NavigationDestination
    }

    private let menuItems: [MenuItem] = [
        MenuItem(id: 0, title: "Cover Flow",  destination: .coverFlow),
        MenuItem(id: 1, title: "Playlists",   destination: .playlists),
        MenuItem(id: 2, title: "Artists",     destination: .artists),
        MenuItem(id: 3, title: "Albums",      destination: .albums),
        MenuItem(id: 4, title: "Songs",       destination: .songs),
        MenuItem(id: 5, title: "Genres",      destination: .genres),
        MenuItem(id: 6, title: "Search",      destination: .search),
    ]

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: "Music",
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(menuItems.enumerated()), id: \.element.id) { index, item in
                        ListRowView(
                            text: item.title,
                            isSelected: appState.selectedIndex == index
                        )
                        .onTapGesture {
                            appState.selectedIndex = index
                            appState.push(item.destination)
                        }

                        if index < menuItems.count - 1 {
                            Divider().padding(.leading, 8)
                        }
                    }
                }
            }
            .background(bgColor)
        }
    }

    private var bgColor: Color {
        appState.appTheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xDDE5ED)
    }
}
