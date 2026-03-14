import SwiftUI

// MARK: - NowPlayingView

/// Replicates the classic iPod Now Playing screen: large album art, track /
/// artist title and an animated progress bar.  The bottom bar cycles through
/// seek, volume, shuffle and rating pages just like the original app.
struct NowPlayingView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var player:   PlayerEngine
    @EnvironmentObject private var library:  LibraryManager

    @State private var bottomPage: NowPlayingPage = .seekBar

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                title: "Now Playing",
                isPlaying: player.isPlaying,
                colorScheme: appState.colorScheme
            )

            if player.queue.isEmpty {
                EmptyStateView(message: "No music selected")
            } else {
                nowPlayingContent
            }
        }
        .background(bgColor)
    }

    // MARK: - Main content

    @ViewBuilder
    private var nowPlayingContent: some View {
        let track = player.currentTrack

        VStack(spacing: 0) {
            // ── Header row (shuffle / repeat icons) ─────────────────────────
            HStack {
                Spacer()
                if player.isShuffled {
                    Image(systemName: "shuffle")
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .padding(.trailing, 6)
                }
                if player.repeatMode != .off {
                    Image(systemName: player.repeatMode == .repeatOne ? "repeat.1" : "repeat")
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .padding(.trailing, 6)
                }
            }
            .frame(height: 18)

            // ── Album art ───────────────────────────────────────────────────
            Group {
                if let artwork = track?.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: 0x3A3A3C))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 120)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            // ── Track info ──────────────────────────────────────────────────
            VStack(spacing: 2) {
                marqueeText(track?.title ?? "—")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)

                Text(track?.artist ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)

            Spacer()

            // ── Progress bar ─────────────────────────────────────────────────
            progressBar

            // ── Bottom control bar ────────────────────────────────────────────
            bottomControlBar

            Spacer(minLength: 4)
        }
    }

    // MARK: - Progress bar

    @ViewBuilder
    private var progressBar: some View {
        let progress = player.duration > 0 ? player.currentTime / player.duration : 0

        VStack(spacing: 2) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0xCCCCCC))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x8694D7), Color(hex: 0x6CA0F7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress), height: 4)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        let ratio = val.location.x / geo.size.width
                        player.seekTo(time: ratio.clamped(to: 0...1) * player.duration)
                    }
                )
            }
            .frame(height: 4)

            HStack {
                Text(formatTime(player.currentTime))
                Spacer()
                Text("-" + formatTime(max(0, player.duration - player.currentTime)))
            }
            .font(.system(size: 9))
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
    }

    // MARK: - Bottom bar pages

    @ViewBuilder
    private var bottomControlBar: some View {
        switch bottomPage {
        case .seekBar:
            seekBarPage
        case .volumeBar:
            volumeBarPage
        case .shuffleBar:
            shuffleBarPage
        case .ratingBar:
            ratingBarPage
        }
    }

    @ViewBuilder private var seekBarPage: some View {
        HStack(spacing: 4) {
            controlButton("backward.end.fill") { player.previousTrack() }
            controlButton(player.isPlaying ? "pause.fill" : "play.fill") { player.togglePlayPause() }
            controlButton("forward.end.fill") { player.nextTrack() }
            Spacer()
            controlButton("repeat") { player.repeatMode = player.repeatMode.next }
                .foregroundColor(player.repeatMode != .off ? Color(hex: 0x5382C9) : .secondary)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
    }

    @ViewBuilder private var volumeBarPage: some View {
        HStack(spacing: 4) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Slider(value: Binding(
                get: { Double(player.volume) },
                set: { player.volume = Float($0) }
            ), in: 0...1)
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
    }

    @ViewBuilder private var shuffleBarPage: some View {
        HStack {
            Text("Shuffle")
                .font(.system(size: 11))
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: Binding(
                get: { player.isShuffled },
                set: { _ in
                    if player.isShuffled { player.unshuffleQueue() }
                    else { player.shuffleQueue() }
                }
            ))
            .toggleStyle(.switch)
            .controlSize(.mini)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
    }

    @ViewBuilder private var ratingBarPage: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: (player.currentTrack?.rating ?? 0) >= star ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x70A9DB))
                    .onTapGesture {
                        if let track = player.currentTrack {
                            library.updateRating(for: track, rating: star)
                        }
                    }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
    }

    @ViewBuilder
    private func controlButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
        .frame(width: 30, height: 28)
    }

    // MARK: - Marquee text

    @ViewBuilder
    private func marqueeText(_ text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private var bgColor: Color {
        appState.appTheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xDDE5ED)
    }

    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite else { return "0:00" }
        let s = Int(t)
        return "\(s / 60):\(String(format: "%02d", s % 60))"
    }
}

// MARK: - NowPlayingPage

private enum NowPlayingPage { case seekBar, volumeBar, shuffleBar, ratingBar }

// MARK: - CGFloat clamped

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.max(range.lowerBound, Swift.min(self, range.upperBound))
    }
}
