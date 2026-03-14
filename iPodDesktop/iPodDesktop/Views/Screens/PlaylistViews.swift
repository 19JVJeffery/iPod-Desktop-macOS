import SwiftUI

// MARK: - PlaylistsView

struct PlaylistsView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var player:   PlayerEngine

    var body: some View {
        iPodListScreen(
            title: "Playlists",
            items: appState.playlists,
            label: { $0.name }
        )
    }
}

// MARK: - PlaylistDetailView

struct PlaylistDetailView: View {

    let playlist: Playlist

    @EnvironmentObject private var appState:  AppState
    @EnvironmentObject private var player:    PlayerEngine
    @EnvironmentObject private var library:   LibraryManager

    private var tracks: [Track] {
        playlist.trackURLs.compactMap { library.trackWith(url: $0) }
    }

    var body: some View {
        iPodListScreen(
            title:    playlist.name,
            items:    tracks,
            label:    { $0.title },
            subLabel: { $0.artist },
            artwork:  { $0.artwork }
        )
    }
}
