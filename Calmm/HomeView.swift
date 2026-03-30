import SwiftUI
import Combine
import AVFoundation

struct HomeView: View {
    @State private var isTailUp = false
    @State private var isPetting = false
    @State private var cryingFrame: Int?
    @State private var cryingTask: Task<Void, Never>?
    @StateObject private var purrPlayer = PurrPlayer()

    private let idleTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let cryingFrames = [1, 2, 3, 4, 5]
    private let pettingThreshold: CGFloat = 18

    private var currentImageName: String {
        if let cryingFrame {
            return "Crying\(cryingFrame)"
        }

        if isPetting {
            return "TouchingCat"
        }

        return isTailUp ? "TailUp" : "TailDown"
    }

    var body: some View {
        GeometryReader { geometry in
            let catSize = min(geometry.size.width * 1.22, geometry.size.height * 0.82)

            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                Image(currentImageName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: catSize, height: catSize)
                    .rotationEffect(.degrees(90))
                    .contentShape(Rectangle())
                    .gesture(catGesture)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .onReceive(idleTimer) { _ in
            guard !isPetting, cryingFrame == nil else { return }
            isTailUp.toggle()
        }
        .onDisappear {
            cryingTask?.cancel()
            cryingTask = nil
            purrPlayer.stop()
        }
    }

    private var catGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let movement = hypot(value.translation.width, value.translation.height)

                guard movement >= pettingThreshold else { return }

                cryingTask?.cancel()
                cryingTask = nil
                cryingFrame = nil
                isPetting = true
                purrPlayer.start()
            }
            .onEnded { value in
                let movement = hypot(value.translation.width, value.translation.height)

                if movement >= pettingThreshold {
                    isPetting = false
                    purrPlayer.stop()
                } else {
                    playCryAnimation()
                }
            }
    }

    private func playCryAnimation() {
        cryingTask?.cancel()
        isPetting = false
        purrPlayer.stop()

        cryingTask = Task {
            for frame in cryingFrames {
                await MainActor.run {
                    cryingFrame = frame
                }

                try? await Task.sleep(for: .milliseconds(110))
            }

            await MainActor.run {
                cryingFrame = nil
                cryingTask = nil
            }
        }
    }
}

final class PurrPlayer: ObservableObject {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
