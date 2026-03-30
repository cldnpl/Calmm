import SwiftUI
import Combine

struct HomeView: View {
    @State private var isTailUp = false
    @State private var isPetting = false
    @State private var cryingFrame: Int?
    @State private var cryingTask: Task<Void, Never>?

    private let idleTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let cryingFrames = [1, 2, 3, 4, 5]
    private let pettingThreshold: CGFloat = 18

    private var currentImageName: String {
        if let cryingFrame {
            return "crying\(cryingFrame)"
        }

        if isPetting {
            return "touchingCat"
        }

        return isTailUp ? "Tailup" : "Taildown"
    }

    var body: some View {
        GeometryReader { geometry in
            let catSize = min(geometry.size.width * 1.22, geometry.size.height * 0.82)

            ZStack {
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
            }
            .onEnded { value in
                let movement = hypot(value.translation.width, value.translation.height)

                if movement >= pettingThreshold {
                    isPetting = false
                } else {
                    playCryAnimation()
                }
            }
    }

    private func playCryAnimation() {
        cryingTask?.cancel()
        isPetting = false

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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
