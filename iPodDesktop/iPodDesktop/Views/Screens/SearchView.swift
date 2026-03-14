import SwiftUI

// MARK: - SearchView

struct SearchView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var library:  LibraryManager
    @EnvironmentObject private var player:   PlayerEngine

    @State private var query = ""
    @State private var selectedIndex = 0

    private var results: [Track] {
        guard !query.isEmpty else { return library.sortedTracks }
        return library.sortedTracks.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query) ||
            $0.albumTitle.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: "Search",
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            // ── Search field ─────────────────────────────────────────────────
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                TextField("Search…", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                if !query.isEmpty {
                    Button(action: { query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(hex: appState.appTheme == .dark ? 0x1C1C1E : 0xF5F5F5))

            Divider()

            // ── Results list ─────────────────────────────────────────────────
            if results.isEmpty {
                EmptyStateView(message: "No results")
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(results.enumerated()), id: \.element.id) { index, track in
                            ListRowView(
                                text: track.title,
                                subText: track.artist,
                                isSelected: selectedIndex == index,
                                artwork: track.artwork,
                                showChevron: false
                            )
                            .onTapGesture {
                                selectedIndex = index
                                player.loadQueue(results, startAt: index)
                                appState.push(.nowPlaying)
                            }
                            if index < results.count - 1 {
                                Divider().padding(.leading, 42)
                            }
                        }
                    }
                }
            }
        }
        .background(bgColor)
    }

    private var bgColor: Color {
        appState.appTheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xDDE5ED)
    }
}
