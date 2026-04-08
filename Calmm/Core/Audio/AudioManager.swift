import AVFoundation
import Foundation

final class AudioManager {
    static let shared = AudioManager()

    private var purrPlayer: AVAudioPlayer?
    private var eatingPlayer: AVAudioPlayer?
    private var eatingStopWorkItem: DispatchWorkItem?

    private let purrCandidates = [
        ("purringCat", "mp3"),
        ("purringCat", "m4a"),
        ("purringCat", "wav"),
        ("purringCat", "caf"),
        ("purr", "mp3"),
        ("purr", "m4a"),
        ("purr", "wav"),
        ("purr", "caf"),
    ]
    private let eatingCandidates = [
        ("eatingSound", "mp3"),
        ("eatingSound", "m4a"),
        ("eatingSound", "wav"),
        ("eatingSound", "caf"),
        ("eat", "mp3"),
        ("eat", "m4a"),
        ("eat", "wav"),
        ("eat", "caf"),
    ]
    private let eatingClipDuration: TimeInterval = 0.42

    private init() {}

    func startPurring() {
        guard let purrPlayer else {
            preparePurrPlayer()
            self.purrPlayer?.play()
            return
        }

        if !purrPlayer.isPlaying {
            purrPlayer.currentTime = 0
            purrPlayer.play()
        }
    }

    func stopPurring() {
        purrPlayer?.stop()
        purrPlayer?.currentTime = 0
    }

    func playEatingSound() {
        prepareEatingPlayer()

        guard let eatingPlayer else { return }

        eatingStopWorkItem?.cancel()
        eatingPlayer.stop()
        eatingPlayer.currentTime = 0
        eatingPlayer.numberOfLoops = 0
        eatingPlayer.play()

        let stopWorkItem = DispatchWorkItem { [weak self] in
            self?.eatingPlayer?.stop()
            self?.eatingPlayer?.currentTime = 0
        }

        eatingStopWorkItem = stopWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + eatingClipDuration, execute: stopWorkItem)
    }

    private func preparePurrPlayer() {
        guard purrPlayer == nil else { return }

        for (name, ext) in purrCandidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                purrPlayer = try? AVAudioPlayer(contentsOf: url)
                purrPlayer?.numberOfLoops = -1
                purrPlayer?.prepareToPlay()
                return
            }
        }
    }

    private func prepareEatingPlayer() {
        guard eatingPlayer == nil else { return }

        for (name, ext) in eatingCandidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                eatingPlayer = try? AVAudioPlayer(contentsOf: url)
                eatingPlayer?.prepareToPlay()
                return
            }
        }
    }
}
