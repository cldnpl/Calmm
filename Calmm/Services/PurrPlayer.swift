import AVFoundation
import Foundation

final class PurrPlayer {
    private var audioPlayer: AVAudioPlayer?
    private let audioCandidates = [
        ("purringCat", "mp3"),
        ("purringCat", "m4a"),
        ("purringCat", "wav"),
        ("purringCat", "caf"),
        ("purr", "mp3"),
        ("purr", "m4a"),
        ("purr", "wav"),
        ("purr", "caf"),
    ]

    func start() {
        guard let audioPlayer else {
            preparePlayer()
            self.audioPlayer?.play()
            return
        }

        if !audioPlayer.isPlaying {
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }

    private func preparePlayer() {
        guard audioPlayer == nil else { return }

        for (resourceName, fileExtension) in audioCandidates {
            if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) {
                audioPlayer = try? AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.prepareToPlay()
                return
            }
        }
    }
}
