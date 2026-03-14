import SwiftUI

// MARK: - CoverFlowView

/// Horizontal-scrolling album art cover flow view replicating the
/// iPod Classic Cover Flow experience.
struct CoverFlowView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var library:  LibraryManager
    @EnvironmentObject private var player:   PlayerEngine

    @State private var selectedAlbumIndex = 0
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: "Cover Flow",
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            if library.albums.isEmpty {
                EmptyStateView(message: "No albums found")
            } else {
                coverFlowContent
            }
        }
        .background(Color.black)
    }

    @ViewBuilder
    private var coverFlowContent: some View {
        let albums = library.albums
        let selected = min(selectedAlbumIndex, albums.count - 1)

        VStack(spacing: 0) {
            // ── Artwork carousel ──────────────────────────────────────────────
            GeometryReader { geo in
                let itemW = geo.size.width * 0.55
                let spacing: CGFloat = 8
                let totalW = (itemW + spacing) * CGFloat(albums.count)

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            ForEach(Array(albums.enumerated()), id: \.element.id) { index, album in
                                coverArtItem(album: album, index: index, itemW: itemW,
                                             isSelected: index == selected)
                                    .id(index)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.22)) {
                                            selectedAlbumIndex = index
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, (geo.size.width - itemW) / 2)
                        .frame(minWidth: totalW)
                    }
                    .onChange(of: selectedAlbumIndex) { idx in
                        withAnimation { proxy.scrollTo(idx, anchor: .center) }
                    }
                }
            }
            .frame(height: 140)

            Divider().background(Color.white.opacity(0.2))

            // ── Track list for selected album ─────────────────────────────────
            if selected < albums.count {
                let album = albums[selected]
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(album.tracks.enumerated()), id: \.element.id) { idx, track in
                            HStack {
                                Text("\(idx + 1)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                Text(track.title)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                appState.selectedIndex == idx
                                    ? Color(hex: 0x5382C9).opacity(0.5)
                                    : Color.clear
                            )
                            .onTapGesture {
                                appState.selectedIndex = idx
                                player.loadQueue(album.tracks, startAt: idx)
                                appState.push(.nowPlaying)
                            }
                            if idx < album.tracks.count - 1 {
                                Divider().background(Color.white.opacity(0.1))
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func coverArtItem(album: Album, index: Int, itemW: CGFloat, isSelected: Bool) -> some View {
        let scale: CGFloat = isSelected ? 1.0 : 0.78
        let rotation: Double = isSelected ? 0 : (index < selectedAlbumIndex ? -40 : 40)

        Group {
            if let artwork = album.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: 0x3A3A3C))
                    .overlay(
                        VStack {
                            Image(systemName: "music.note.list")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                            Text(album.title)
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 4)
                        }
                    )
            }
        }
        .frame(width: itemW, height: itemW)
        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.6
        )
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.22), value: isSelected)
    }
}
