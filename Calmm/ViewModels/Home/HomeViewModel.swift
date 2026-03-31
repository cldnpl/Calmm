import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var isTailUp = false
    @Published private(set) var isPetting = false
    @Published private(set) var cryingFrame: Int?

    private let cryingFrames = [1, 2, 3, 4, 5]
    private let pettingThreshold: CGFloat = 18

    private let purrPlayer: PurrPlayer
    private var cryingTask: Task<Void, Never>?

    init(purrPlayer: PurrPlayer = PurrPlayer()) {
        self.purrPlayer = purrPlayer
    }

    var currentImageName: String {
        if let cryingFrame {
            return "Crying\(cryingFrame)"
        }

        if isPetting {
            return "TouchingCat"
        }

        return isTailUp ? "TailUp" : "TailDown"
    }

    func handleIdleTick() {
        guard !isPetting, cryingFrame == nil else { return }
        isTailUp.toggle()
    }

    func handleDragChanged(translation: CGSize) {
        let movement = hypot(translation.width, translation.height)
        guard movement >= pettingThreshold else { return }

        cryingTask?.cancel()
        cryingTask = nil
        cryingFrame = nil
        isPetting = true
        purrPlayer.start()
    }

    func handleDragEnded(translation: CGSize) {
        let movement = hypot(translation.width, translation.height)

        if movement >= pettingThreshold {
            isPetting = false
            purrPlayer.stop()
        } else {
            playCryAnimation()
        }
    }

    func cleanup() {
        cryingTask?.cancel()
        cryingTask = nil
        purrPlayer.stop()
    }

    private func playCryAnimation() {
        cryingTask?.cancel()
        isPetting = false
        purrPlayer.stop()

        cryingTask = Task { [weak self] in
            await self?.runCryAnimation()
        }
    }

    private func runCryAnimation() async {
        for frame in cryingFrames {
            cryingFrame = frame
            try? await Task.sleep(for: .milliseconds(110))
        }

        cryingFrame = nil
        cryingTask = nil
    }
}
