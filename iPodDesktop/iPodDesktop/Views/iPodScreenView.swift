import SwiftUI

// MARK: - iPodScreenView

/// The rectangular display area of the iPod, hosting whatever screen the
/// navigation stack currently calls for.
struct iPodScreenView: View {
    @EnvironmentObject var appState:  AppState
    @EnvironmentObject var player:    PlayerEngine
    @EnvironmentObject var library:   LibraryManager

    var body: some View {
        ZStack {
            // Screen background
            Color(hex: appState.appTheme == .dark ? 0x121212 : 0xDDE5ED)

            // Route the current destination to the right screen
            Group {
                switch appState.currentDestination {
                case .mainMenu:
                    MainMenuView()

                case .musicMenu:
                    MusicMenuView()

                case .songs:
                    SongsListView(tracks: library.sortedTracks)

                case .albums:
                    AlbumsGridView(albums: library.albums)

                case .albumDetail(let album):
                    TrackListView(
                        title: album.title,
                        tracks: album.tracks,
                        headerArtwork: album.artwork
                    )

                case .artists:
                    ArtistsListView(artists: library.artists)

                case .artistDetail(let artist):
                    ArtistDetailView(artist: artist)

                case .genres:
                    GenresListView(genres: library.genres)

                case .genreDetail(let genre):
                    TrackListView(
                        title: genre.name,
                        tracks: genre.tracks,
                        headerArtwork: nil
                    )

                case .playlists:
                    PlaylistsView()

                case .playlistDetail(let playlist):
                    PlaylistDetailView(playlist: playlist)

                case .nowPlaying:
                    NowPlayingView()

                case .settings:
                    SettingsView()

                case .search:
                    SearchView()

                case .coverFlow:
                    CoverFlowView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.18), value: appState.currentDestination)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black, lineWidth: 1.5)
        )
    }
}
