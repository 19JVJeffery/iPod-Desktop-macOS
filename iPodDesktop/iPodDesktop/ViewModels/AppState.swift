import Combine
import Foundation

// MARK: - NavigationDestination

/// Every screen the iPod can navigate to.
enum NavigationDestination: Hashable, Equatable {
    case mainMenu
    case musicMenu
    case songs
    case albums
    case albumDetail(Album)
    case artists
    case artistDetail(Artist)
    case genres
    case genreDetail(Genre)
    case playlists
    case playlistDetail(Playlist)
    case nowPlaying
    case settings
    case search
    case coverFlow

    var title: String {
        switch self {
        case .mainMenu:                 return "iPod"
        case .musicMenu:                return "Music"
        case .songs:                    return "Songs"
        case .albums:                   return "Albums"
        case .albumDetail(let a):       return a.title
        case .artists:                  return "Artists"
        case .artistDetail(let a):      return a.name
        case .genres:                   return "Genres"
        case .genreDetail(let g):       return g.name
        case .playlists:                return "Playlists"
        case .playlistDetail(let p):    return p.name
        case .nowPlaying:               return "Now Playing"
        case .settings:                 return "Settings"
        case .search:                   return "Search"
        case .coverFlow:                return "Cover Flow"
        }
    }
}

// MARK: - AppTheme

enum AppTheme: String, CaseIterable, Codable {
    case light, dark

    var displayName: String { rawValue.capitalized }
}

// MARK: - AppState

/// Central observable store for the entire application.
/// Owns the navigation stack, settings and playlist storage.
@MainActor
final class AppState: ObservableObject {

    // MARK: Navigation

    @Published var navigationStack: [NavigationDestination] = [.mainMenu]
    @Published var selectedIndex: Int = 0

    var currentDestination: NavigationDestination { navigationStack.last ?? .mainMenu }

    func push(_ destination: NavigationDestination) {
        navigationStack.append(destination)
        selectedIndex = 0
    }

    func pop() {
        guard navigationStack.count > 1 else { return }
        navigationStack.removeLast()
        selectedIndex = 0
    }

    func popToRoot() {
        navigationStack = [.mainMenu]
        selectedIndex = 0
    }

    // MARK: Settings (persisted via UserDefaults)

    @Published var colorScheme: iPodColorScheme = .silver {
        didSet { UserDefaults.standard.set(colorScheme.rawValue, forKey: "colorScheme") }
    }

    @Published var appTheme: AppTheme = .light {
        didSet { UserDefaults.standard.set(appTheme.rawValue, forKey: "appTheme") }
    }

    @Published var clickWheelSoundEnabled: Bool = true {
        didSet { UserDefaults.standard.set(clickWheelSoundEnabled, forKey: "clickWheelSound") }
    }

    // MARK: Playlists (persisted)

    @Published var playlists: [Playlist] = [] {
        didSet { persistPlaylists() }
    }

    // MARK: Init

    init() {
        loadSettings()
        loadPlaylists()
    }

    // MARK: Playlist management

    func createPlaylist(named name: String) {
        playlists.append(Playlist(name: name))
    }

    func renamePlaylist(_ playlist: Playlist, to name: String) {
        guard let idx = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[idx].name = name
    }

    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
    }

    func addTrack(_ track: Track, to playlist: Playlist) {
        guard let idx = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        if !playlists[idx].trackURLs.contains(track.fileURL) {
            playlists[idx].trackURLs.append(track.fileURL)
        }
    }

    func removeTrack(_ track: Track, from playlist: Playlist) {
        guard let idx = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        playlists[idx].trackURLs.removeAll { $0 == track.fileURL }
    }

    // MARK: Private persistence helpers

    private func loadSettings() {
        let ud = UserDefaults.standard
        if let raw = ud.string(forKey: "colorScheme"),
           let scheme = iPodColorScheme(rawValue: raw) { colorScheme = scheme }
        if let raw = ud.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: raw) { appTheme = theme }
        clickWheelSoundEnabled = ud.object(forKey: "clickWheelSound") as? Bool ?? true
    }

    private func persistPlaylists() {
        if let data = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(data, forKey: "playlists")
        }
    }

    private func loadPlaylists() {
        guard let data = UserDefaults.standard.data(forKey: "playlists"),
              let saved = try? JSONDecoder().decode([Playlist].self, from: data) else { return }
        playlists = saved
    }
}
