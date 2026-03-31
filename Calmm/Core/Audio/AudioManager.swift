import AVFoundation
import Foundation

final class AudioManager {
    static let shared = AudioManager()

    private var purrPlayer: AVAudioPlayer?

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
}
