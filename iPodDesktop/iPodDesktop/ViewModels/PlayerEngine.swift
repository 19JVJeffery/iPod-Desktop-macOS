import AVFoundation
import Combine
import Foundation

// MARK: - RepeatMode

enum RepeatMode: Int, CaseIterable, Codable {
    case off, repeatAll, repeatOne

    var next: RepeatMode {
        switch self {
        case .off:       return .repeatAll
        case .repeatAll: return .repeatOne
        case .repeatOne: return .off
        }
    }
}

// MARK: - PlayerEngine

/// Manages audio playback using AVQueuePlayer.
/// All mutations and notifications happen on the main actor.
@MainActor
final class PlayerEngine: NSObject, ObservableObject {

    // MARK: Published state

    @Published private(set) var currentTrack: Track?
    @Published private(set) var queue: [Track] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var volume: Float = 1.0 {
        didSet { player.volume = volume }
    }
    @Published var repeatMode: RepeatMode = .off
    @Published var isShuffled = false

    // MARK: Private

    private let player = AVPlayer()
    private var timeObserver: Any?
    private var itemEndObserver: NSObjectProtocol?
    private var statusCancellable: AnyCancellable?
    private var shuffledIndices: [Int] = []

    // MARK: Init / deinit

    override init() {
        super.init()
        configureTimeObserver()
        configureEndObserver()
    }

    deinit {
        if let obs = timeObserver { player.removeTimeObserver(obs) }
        if let obs = itemEndObserver { NotificationCenter.default.removeObserver(obs) }
    }

    // MARK: Playback control

    func loadQueue(_ tracks: [Track], startAt index: Int = 0) {
        queue = tracks
        currentIndex = index.clamped(to: 0 ..< max(1, tracks.count))
        if isShuffled { buildShuffledOrder(keepCurrentAt: currentIndex) }
        playCurrentItem()
    }

    func play() {
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func nextTrack() {
        let count = queue.count
        guard count > 0 else { return }
        switch repeatMode {
        case .repeatOne:
            seekTo(time: 0); play()
        case .repeatAll:
            currentIndex = (currentIndex + 1) % count
            playCurrentItem()
        case .off:
            if currentIndex < count - 1 {
                currentIndex += 1
                playCurrentItem()
            } else {
                pause()
                seekTo(time: 0)
            }
        }
    }

    func previousTrack() {
        if currentTime > 3 {
            seekTo(time: 0)
            return
        }
        guard queue.count > 0 else { return }
        currentIndex = max(0, currentIndex - 1)
        playCurrentItem()
    }

    func seekTo(time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = time
    }

    func seekForward(by seconds: TimeInterval = 5) {
        seekTo(time: min(currentTime + seconds, duration))
    }

    func seekBackward(by seconds: TimeInterval = 5) {
        seekTo(time: max(0, currentTime - seconds))
    }

    func shuffleQueue() {
        isShuffled = true
        buildShuffledOrder(keepCurrentAt: currentIndex)
    }

    func unshuffleQueue() {
        isShuffled = false
        shuffledIndices = []
    }

    func increaseVolume() {
        volume = min(1.0, volume + 0.05)
    }

    func decreaseVolume() {
        volume = max(0.0, volume - 0.05)
    }

    // MARK: Private helpers

    private func playCurrentItem() {
        guard currentIndex < queue.count else { return }
        let track = queue[currentIndex]
        currentTrack = track
        duration = track.duration

        let item = AVPlayerItem(url: track.fileURL)
        player.replaceCurrentItem(with: item)
        player.volume = volume
        play()

        statusCancellable = item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .readyToPlay { self?.duration = item.asset.duration.seconds }
            }
    }

    private func configureTimeObserver() {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor [weak self] in
                self?.currentTime = time.seconds.isNaN ? 0 : time.seconds
            }
        }
    }

    private func configureEndObserver() {
        itemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.nextTrack() }
        }
    }

    private func buildShuffledOrder(keepCurrentAt index: Int) {
        var indices = Array(0 ..< queue.count)
        indices.remove(at: index)
        indices.shuffle()
        indices.insert(index, at: 0)
        shuffledIndices = indices
    }
}

// MARK: - Int clamped helper

private extension Int {
    func clamped(to range: Range<Int>) -> Int {
        Swift.max(range.lowerBound, Swift.min(self, range.upperBound - 1))
    }
}
