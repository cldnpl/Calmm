import Combine
import SwiftUI

struct HomeView: View {
    @Environment(CatNeedsViewModel.self) private var needsViewModel
    @State private var viewModel = HomeViewModel()

    private let idleTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            CatSceneView(
                imageName: viewModel.currentImageName,
                catGesture: catGesture
            )

            CatNeedsOverlayView(
                hunger: needsViewModel.hungerPercentage,
                cleanliness: needsViewModel.cleanlinessPercentage
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 580)
        }
        .overlay(alignment: .topTrailing) {
            coinsBadge
                .padding(.top, 18)
                .padding(.trailing, 10)
        }
        .onReceive(idleTimer) { _ in
            viewModel.handleIdleTick()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    private var catGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                viewModel.handleDragChanged(translation: value.translation)
            }
            .onEnded { value in
                viewModel.handleDragEnded(translation: value.translation)
            }
    }

    private var coinsBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(hex: "E4A64B"))

            Text("\(needsViewModel.coinCount) coins")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "5A392D"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.white.opacity(0.54))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}

#Preview {
    let needsViewModel = CatNeedsViewModel()
    needsViewModel.loadPreview(hunger: 76, cleanliness: 88)

    return HomeView()
        .environment(needsViewModel)
}
