import Foundation
import AppKit

// MARK: - Track

/// Represents a single audio file with its associated metadata.
struct Track: Identifiable, Hashable, Codable {
    let id: UUID
    let fileURL: URL
    var title: String
    var artist: String
    var albumTitle: String
    var genre: String
    var trackNumber: Int
    var duration: TimeInterval
    var artworkData: Data?
    var rating: Int          // 0–5 stars
    var lyrics: String

    init(
        id: UUID = UUID(),
        fileURL: URL,
        title: String = "",
        artist: String = "",
        albumTitle: String = "",
        genre: String = "",
        trackNumber: Int = 0,
        duration: TimeInterval = 0,
        artworkData: Data? = nil,
        rating: Int = 0,
        lyrics: String = ""
    ) {
        self.id = id
        self.fileURL = fileURL
        self.title = title.isEmpty ? fileURL.deletingPathExtension().lastPathComponent : title
        self.artist = artist.isEmpty ? "Unknown Artist" : artist
        self.albumTitle = albumTitle.isEmpty ? "Unknown Album" : albumTitle
        self.genre = genre.isEmpty ? "Unknown Genre" : genre
        self.trackNumber = trackNumber
        self.duration = duration
        self.artworkData = artworkData
        self.rating = max(0, min(5, rating))
        self.lyrics = lyrics
    }

    /// Resolves artwork data into an NSImage for display.
    var artwork: NSImage? {
        guard let data = artworkData else { return nil }
        return NSImage(data: data)
    }

    static func == (lhs: Track, rhs: Track) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Album

/// Groups tracks sharing the same album title and artist.
struct Album: Identifiable, Hashable {
    let id: String           // "Artist — Album" key
    let title: String
    let artist: String
    var tracks: [Track]

    var artwork: NSImage? { tracks.compactMap(\.artwork).first }

    static func == (lhs: Album, rhs: Album) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Artist

/// Groups albums by the same artist name.
struct Artist: Identifiable, Hashable {
    let id: String           // artist name used as key
    let name: String
    var albums: [Album]

    var artwork: NSImage? { albums.compactMap(\.artwork).first }

    static func == (lhs: Artist, rhs: Artist) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Genre

/// Groups tracks by genre tag.
struct Genre: Identifiable, Hashable {
    let id: String           // genre name used as key
    let name: String
    var tracks: [Track]

    static func == (lhs: Genre, rhs: Genre) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
