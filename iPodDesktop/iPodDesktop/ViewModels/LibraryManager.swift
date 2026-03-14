import AVFoundation
import Combine
import Foundation

// MARK: - LibraryManager

/// Scans user-selected folders for audio files, reads their metadata via
/// AVFoundation and caches the resulting `Track` array.  All heavy work runs
/// on a background actor so the main thread is never blocked.
@MainActor
final class LibraryManager: ObservableObject {

    // MARK: Published state

    @Published private(set) var tracks: [Track] = []
    @Published private(set) var isScanning = false
    @Published private(set) var scanProgress: Double = 0          // 0 … 1
    @Published var scanFolderURL: URL? {
        didSet { persistScanFolder(); Task { await rescan() } }
    }

    // MARK: Derived collections (computed on demand)

    var albums: [Album] {
        let grouped = Dictionary(grouping: tracks) { t in "\(t.artist)—\(t.albumTitle)" }
        return grouped
            .map { key, tracks in
                Album(id: key,
                      title: tracks[0].albumTitle,
                      artist: tracks[0].artist,
                      tracks: tracks.sorted { ($0.trackNumber, $0.title) < ($1.trackNumber, $1.title) })
            }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var artists: [Artist] {
        let byArtist = Dictionary(grouping: albums) { $0.artist }
        return byArtist
            .map { name, albums in
                Artist(id: name, name: name,
                       albums: albums.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var genres: [Genre] {
        let grouped = Dictionary(grouping: tracks) { $0.genre }
        return grouped
            .map { name, tracks in
                Genre(id: name, name: name,
                      tracks: tracks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var sortedTracks: [Track] {
        tracks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    // MARK: Persistence keys

    private let folderBookmarkKey = "scanFolderBookmark"
    private let cachedTracksKey   = "cachedTracksData"

    // MARK: Init

    init() {
        restoreScanFolder()
        loadCachedTracks()
    }

    // MARK: Public API

    func rescan() async {
        guard let url = scanFolderURL else { return }
        isScanning = true
        scanProgress = 0
        let found = await scanDirectory(url)
        tracks = found
        isScanning = false
        scanProgress = 1
        cacheTracks()
    }

    func trackWith(url: URL) -> Track? {
        tracks.first { $0.fileURL == url }
    }

    func updateRating(for track: Track, rating: Int) {
        guard let idx = tracks.firstIndex(where: { $0.id == track.id }) else { return }
        tracks[idx].rating = max(0, min(5, rating))
        cacheTracks()
    }

    // MARK: Scanning

    private static let supportedExtensions: Set<String> = [
        "mp3", "wav", "ogg", "flac", "m4a", "aac", "aiff", "alac", "opus"
    ]

    private func scanDirectory(_ root: URL) async -> [Track] {
        let fm = FileManager.default
        guard root.startAccessingSecurityScopedResource() else { return [] }
        defer { root.stopAccessingSecurityScopedResource() }

        var audioURLs: [URL] = []
        let enumerator = fm.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
        while let url = enumerator?.nextObject() as? URL {
            let ext = url.pathExtension.lowercased()
            if Self.supportedExtensions.contains(ext) {
                audioURLs.append(url)
            }
        }

        let total = audioURLs.count
        guard total > 0 else { return [] }
        var result: [Track] = []

        for (index, url) in audioURLs.enumerated() {
            let track = await readMetadata(from: url)
            result.append(track)
            scanProgress = Double(index + 1) / Double(total)
        }
        return result
    }

    private func readMetadata(from url: URL) async -> Track {
        let asset = AVURLAsset(url: url)
        var title = ""
        var artist = ""
        var album = ""
        var genre = ""
        var trackNumber = 0
        var duration: TimeInterval = 0
        var artworkData: Data?
        var lyrics = ""

        do {
            let items = try await asset.load(.commonMetadata)
            for item in items {
                guard let key = item.commonKey else { continue }
                switch key {
                case .commonKeyTitle:
                    title = (try? await item.load(.stringValue)) ?? ""
                case .commonKeyArtist:
                    artist = (try? await item.load(.stringValue)) ?? ""
                case .commonKeyAlbumName:
                    album = (try? await item.load(.stringValue)) ?? ""
                case .commonKeyArtwork:
                    artworkData = try? await item.load(.dataValue)
                default: break
                }
            }

            // Extended metadata (genre, track number, lyrics)
            let allMeta = try await asset.load(.metadata)
            for item in allMeta {
                let keySpace = item.keySpace
                if keySpace == .id3 || keySpace == .iTunes {
                    if let strKey = item.key as? String {
                        let lower = strKey.lowercased()
                        if lower.contains("genre") || lower == "gnre" || lower == "@gen" {
                            genre = (try? await item.load(.stringValue)) ?? ""
                        } else if lower.contains("track") || lower == "trck" || lower == "trkn" {
                            let raw = (try? await item.load(.stringValue)) ?? ""
                            trackNumber = Int(raw.split(separator: "/").first ?? "0") ?? 0
                        } else if lower.contains("lyric") || lower == "uslt" || lower == "@lyr" {
                            lyrics = (try? await item.load(.stringValue)) ?? ""
                        }
                    }
                }
            }

            let durationValue = try await asset.load(.duration)
            duration = durationValue.seconds.isNaN ? 0 : durationValue.seconds
        } catch { /* use defaults */ }

        return Track(
            fileURL: url,
            title: title,
            artist: artist,
            albumTitle: album,
            genre: genre,
            trackNumber: trackNumber,
            duration: duration,
            artworkData: artworkData,
            lyrics: lyrics
        )
    }

    // MARK: Persistence

    private func persistScanFolder() {
        guard let url = scanFolderURL,
              let bookmark = try? url.bookmarkData(options: .withSecurityScope) else { return }
        UserDefaults.standard.set(bookmark, forKey: folderBookmarkKey)
    }

    private func restoreScanFolder() {
        guard let bookmark = UserDefaults.standard.data(forKey: folderBookmarkKey) else { return }
        var stale = false
        let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            bookmarkDataIsStale: &stale
        )
        scanFolderURL = url
    }

    private func cacheTracks() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(tracks) {
            UserDefaults.standard.set(data, forKey: cachedTracksKey)
        }
    }

    private func loadCachedTracks() {
        guard let data = UserDefaults.standard.data(forKey: cachedTracksKey),
              let cached = try? JSONDecoder().decode([Track].self, from: data) else { return }
        tracks = cached
    }
}
