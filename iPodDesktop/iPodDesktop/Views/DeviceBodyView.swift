import SwiftUI

// MARK: - DeviceBodyView

/// The complete iPod Classic device — frame, screen and click wheel — drawn
/// entirely in SwiftUI with no images required.  The aspect ratio and
/// proportions match the physical iPod Classic (5th / 6th gen).
struct DeviceBodyView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var player:   PlayerEngine
    @EnvironmentObject var library:  LibraryManager

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                deviceFrame(width: w, height: h)
                deviceContents(width: w, height: h)
                reflectionOverlay(width: w, height: h)
            }
        }
    }

    // MARK: - Device frame (gradient body)

    @ViewBuilder
    private func deviceFrame(width: CGFloat, height: CGFloat) -> some View {
        let scheme = appState.colorScheme
        let r      = ContentView.deviceCornerRadius

        ZStack {
            // Base gradient
            RoundedRectangle(cornerRadius: r, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [scheme.frameTopColor, scheme.frameBottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Noise grain overlay (simulated with a very subtle opacity pattern)
            RoundedRectangle(cornerRadius: r, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(scheme.noiseOpacity * 0.08),
                            Color.clear,
                            Color.black.opacity(0.04),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Edge shadow ring
            RoundedRectangle(cornerRadius: r, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.black.opacity(0.30),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.2
                )
        }
        // No explicit drop shadow here — the system window shadow (from the
        // transparent-window setup in WindowConfigurator) handles the outer glow.
    }

    // MARK: - Screen + Click Wheel layout

    @ViewBuilder
    private func deviceContents(width: CGFloat, height: CGFloat) -> some View {
        let hPad    = width  * 0.072
        let vPad    = height * 0.040
        let screenW = width  - hPad * 2
        // iPod Classic screen is wider than tall: 320 px wide × 240 px tall (4:3
        // landscape). So screen height = screen width × ¾ faithfully reproduces
        // the real device proportions.
        let screenH = screenW * 0.75
        let wheelD  = width  * 0.74

        VStack(spacing: 0) {
            // ── Hold switch row ─────────────────────────────────────────────
            HStack {
                Spacer()
                holdSwitchIndicator(width: width)
                    .padding(.trailing, hPad)
            }
            .frame(height: height * 0.040)

            // ── Screen ──────────────────────────────────────────────────────
            iPodScreenView()
                .frame(
                    width:  screenW,
                    height: screenH
                )
                .padding(.horizontal, hPad)

            Spacer()

            // ── Click Wheel ──────────────────────────────────────────────────
            ClickWheelView(
                onMenu:    { handleMenu() },
                onForward: { player.nextTrack() },
                onPlay:    { player.togglePlayPause() },
                onBack:    { player.previousTrack() },
                onSelect:  { handleSelect() },
                onRotate:  { delta in handleRotate(delta) }
            )
            .frame(width: wheelD, height: wheelD)

            Spacer()
        }
        .padding(.vertical, vPad)
    }

    // MARK: - Hold switch decoration

    @ViewBuilder
    private func holdSwitchIndicator(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.5))
            .frame(width: width * 0.10, height: 6)
    }

    // MARK: - Reflection overlay (top-left sheen)

    @ViewBuilder
    private func reflectionOverlay(width: CGFloat, height: CGFloat) -> some View {
        let cornerR = ContentView.deviceCornerRadius

        RoundedRectangle(cornerRadius: cornerR, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.22),
                        Color.white.opacity(0.0),
                    ],
                    startPoint: UnitPoint(x: 0.1, y: 0),
                    endPoint:   UnitPoint(x: 0.6, y: 0.5)
                )
            )
            .allowsHitTesting(false)
    }

    // MARK: - Button actions

    private func handleMenu() {
        appState.pop()
    }

    private func handleSelect() {
        let dest = appState.currentDestination
        switch dest {
        case .mainMenu:
            let idx = appState.selectedIndex
            switch idx {
            case 0: appState.push(.musicMenu)
            case 1: appState.push(.settings)
            case 2:
                let all = library.sortedTracks
                guard !all.isEmpty else { return }
                var shuffled = all; shuffled.shuffle()
                player.loadQueue(shuffled, startAt: 0)
                appState.push(.nowPlaying)
            case 3: appState.push(.nowPlaying)
            default: break
            }

        case .musicMenu:
            let idx = appState.selectedIndex
            switch idx {
            case 0: appState.push(.coverFlow)
            case 1: appState.push(.playlists)
            case 2: appState.push(.artists)
            case 3: appState.push(.albums)
            case 4: appState.push(.songs)
            case 5: appState.push(.genres)
            case 6: appState.push(.search)
            default: break
            }

        case .songs:
            let all = library.sortedTracks
            guard appState.selectedIndex < all.count else { return }
            player.loadQueue(all, startAt: appState.selectedIndex)
            appState.push(.nowPlaying)

        case .albums:
            let albums = library.albums
            guard appState.selectedIndex < albums.count else { return }
            appState.push(.albumDetail(albums[appState.selectedIndex]))

        case .albumDetail(let album):
            guard appState.selectedIndex < album.tracks.count else { return }
            player.loadQueue(album.tracks, startAt: appState.selectedIndex)
            appState.push(.nowPlaying)

        case .artists:
            let artists = library.artists
            guard appState.selectedIndex < artists.count else { return }
            appState.push(.artistDetail(artists[appState.selectedIndex]))

        case .artistDetail(let artist):
            guard appState.selectedIndex < artist.albums.count else { return }
            appState.push(.albumDetail(artist.albums[appState.selectedIndex]))

        case .genres:
            let genres = library.genres
            guard appState.selectedIndex < genres.count else { return }
            appState.push(.genreDetail(genres[appState.selectedIndex]))

        case .genreDetail(let genre):
            guard appState.selectedIndex < genre.tracks.count else { return }
            player.loadQueue(genre.tracks, startAt: appState.selectedIndex)
            appState.push(.nowPlaying)

        case .playlists:
            let playlists = appState.playlists
            guard appState.selectedIndex < playlists.count else { return }
            appState.push(.playlistDetail(playlists[appState.selectedIndex]))

        case .playlistDetail(let playlist):
            let tracks = playlist.trackURLs.compactMap { library.trackWith(url: $0) }
            guard appState.selectedIndex < tracks.count else { return }
            player.loadQueue(tracks, startAt: appState.selectedIndex)
            appState.push(.nowPlaying)

        default:
            break
        }
    }

    private func handleRotate(_ delta: Int) {
        let dest = appState.currentDestination
        var count = 0
        switch dest {
        case .mainMenu:       count = MainMenuView.itemCount
        case .musicMenu:      count = MusicMenuView.itemCount
        case .songs:          count = library.sortedTracks.count
        case .albums:         count = library.albums.count
        case .artists:        count = library.artists.count
        case .genres:         count = library.genres.count
        case .playlists:      count = appState.playlists.count
        case .albumDetail(let a): count = a.tracks.count
        case .artistDetail(let a): count = a.albums.count
        case .genreDetail(let g): count = g.tracks.count
        case .playlistDetail(let p): count = p.trackURLs.count
        case .nowPlaying:
            if delta > 0 { player.increaseVolume() }
            else { player.decreaseVolume() }
            return
        case .settings:       count = SettingsView.itemCount
        default:              return
        }
        if count > 0 {
            appState.selectedIndex = (appState.selectedIndex + delta)
                .clamped(to: 0 ..< count)
        }
    }
}

// MARK: - Int clamped helper

private extension Int {
    func clamped(to range: Range<Int>) -> Int {
        Swift.max(range.lowerBound, Swift.min(self, range.upperBound - 1))
    }
}
