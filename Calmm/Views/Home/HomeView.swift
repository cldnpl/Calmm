import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var needsViewModel: CatNeedsViewModel
    @StateObject private var viewModel = HomeViewModel()

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
            .padding(.bottom, 122)
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
}

@MainActor
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let needsViewModel = CatNeedsViewModel()
        needsViewModel.loadPreview(hunger: 76, cleanliness: 88)

        return HomeView()
            .environmentObject(needsViewModel)
    }
}
