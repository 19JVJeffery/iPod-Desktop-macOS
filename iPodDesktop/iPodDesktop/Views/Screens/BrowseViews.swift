import SwiftUI

// MARK: - SongsListView

struct SongsListView: View {
    let tracks: [Track]

    var body: some View {
        iPodListScreen(
            title:    "Songs",
            items:    tracks,
            label:    { $0.title },
            subLabel: { $0.artist },
            artwork:  { $0.artwork }
        )
    }
}

// MARK: - AlbumsGridView  (rendered as a list on the small iPod screen)

struct AlbumsGridView: View {
    let albums: [Album]

    var body: some View {
        iPodListScreen(
            title:   "Albums",
            items:   albums,
            label:   { $0.title },
            subLabel: { $0.artist },
            artwork: { $0.artwork }
        )
    }
}

// MARK: - ArtistsListView

struct ArtistsListView: View {
    let artists: [Artist]

    var body: some View {
        iPodListScreen(
            title:   "Artists",
            items:   artists,
            label:   { $0.name },
            artwork: { $0.artwork }
        )
    }
}

// MARK: - ArtistDetailView  (albums by a single artist)

struct ArtistDetailView: View {
    let artist: Artist

    var body: some View {
        iPodListScreen(
            title:   artist.name,
            items:   artist.albums,
            label:   { $0.title },
            artwork: { $0.artwork }
        )
    }
}

// MARK: - GenresListView

struct GenresListView: View {
    let genres: [Genre]

    var body: some View {
        iPodListScreen(
            title: "Genres",
            items: genres,
            label: { $0.name }
        )
    }
}

// MARK: - TrackListView  (album / genre track listing)

struct TrackListView: View {
    let title:         String
    let tracks:        [Track]
    let headerArtwork: NSImage?

    var body: some View {
        iPodListScreen(
            title:    title,
            items:    tracks,
            label:    { $0.title },
            subLabel: { $0.artist },
            artwork:  { _ in nil }      // no per-row artwork — header handles it
        )
    }
}
