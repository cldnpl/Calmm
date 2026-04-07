import Combine
import SwiftUI

struct HomeView: View {
    @Environment(CatNeedsViewModel.self) private var needsViewModel
    @State private var viewModel = HomeViewModel()
    @State private var catFrame: CGRect = .zero
    @State private var activeDraggedFood: ActiveDraggedFood?
    @State private var isFeedButtonAnimating = false

    private let idleTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            contentLayer

            if needsViewModel.isFeedingModeActive {
                feedingTray
                    .padding(.horizontal, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .coordinateSpace(name: "home-space")
        .overlay(alignment: .topLeading) {
            feedButton
                .padding(.top, 18)
                .padding(.leading, 14)
        }
        .overlay(alignment: .topTrailing) {
            coinsBadge
                .padding(.top, 18)
                .padding(.trailing, 10)
        }
        .overlay {
            if let activeDraggedFood {
                FoodDragPreview(food: activeDraggedFood.entry.food)
                    .position(activeDraggedFood.location)
                    .allowsHitTesting(false)
            }
        }
        .onReceive(idleTimer) { _ in
            viewModel.handleIdleTick()
        }
        .onAppear {
            syncFeedButtonAnimation()
        }
        .onChange(of: needsViewModel.hungerPercentage) { _, _ in
            syncFeedButtonAnimation()
        }
        .onChange(of: needsViewModel.isFeedingModeActive) { _, _ in
            syncFeedButtonAnimation()
        }
        .onDisappear {
            viewModel.cleanup()
            needsViewModel.endFeedingMode()
        }
    }

    private var contentLayer: some View {
        ZStack(alignment: .bottom) {
            CatSceneView(
                imageName: viewModel.currentImageName,
                accessoryImageNames: needsViewModel.equippedAccessoryAssetNames,
                catGesture: catGesture,
                isInteractionEnabled: !needsViewModel.isFeedingModeActive,
                onCatFrameChange: { frame in
                    catFrame = frame
                }
            )

            CatNeedsOverlayView(
                hunger: needsViewModel.hungerPercentage,
                cleanliness: needsViewModel.cleanlinessPercentage
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 580)
        }
    }

    private var catGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !needsViewModel.isFeedingModeActive else { return }
                viewModel.handleDragChanged(translation: value.translation)
            }
            .onEnded { value in
                guard !needsViewModel.isFeedingModeActive else { return }
                viewModel.handleDragEnded(translation: value.translation)
            }
    }

    private var feedButton: some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                needsViewModel.toggleFeedingMode()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: needsViewModel.isFeedingModeActive ? "xmark.circle.fill" : "fork.knife.circle.fill")
                    .font(.system(size: 16, weight: .bold))

                Text(needsViewModel.isFeedingModeActive ? "Close" : "Feed")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(feedButtonBackground)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.72), lineWidth: 1)
            )
            .shadow(color: Color(hex: "D85A30").opacity(0.26), radius: 12, y: 6)
            .scaleEffect(shouldPulseFeedButton ? (isFeedButtonAnimating ? 1.05 : 0.94) : 1)
            .opacity(shouldPulseFeedButton ? (isFeedButtonAnimating ? 1 : 0.55) : 1)
        }
        .buttonStyle(.plain)
    }

    private var feedingTray: some View {
        FoodInventoryTrayView(
            foods: needsViewModel.availableFoods,
            activeFoodID: activeDraggedFood?.entry.id,
            onDragChanged: { entry, location in
                activeDraggedFood = ActiveDraggedFood(entry: entry, location: location)
            },
            onDragEnded: { entry, location in
                defer { activeDraggedFood = nil }

                guard catFrame.contains(location) else { return }
                _ = needsViewModel.feedCat(using: entry.id)
            }
        )
    }

    private var shouldPulseFeedButton: Bool {
        needsViewModel.hungerPercentage < 40 && !needsViewModel.isFeedingModeActive
    }

    private var feedButtonBackground: LinearGradient {
        LinearGradient(
            colors: shouldPulseFeedButton
                ? [Color(hex: "FF7A59"), Color(hex: "D85A30")]
                : [Color(hex: "F0997B"), Color(hex: "D85A30")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func syncFeedButtonAnimation() {
        if shouldPulseFeedButton {
            withAnimation(.easeInOut(duration: 0.72).repeatForever(autoreverses: true)) {
                isFeedButtonAnimating = true
            }
        } else {
            isFeedButtonAnimating = false
        }
    }

    private var coinsBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(hex: "E4A64B"))

            Text(needsViewModel.coinCountText)
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

private struct ActiveDraggedFood: Equatable {
    let entry: CatFoodInventoryEntry
    let location: CGPoint
}

private struct FoodDragPreview: View {
    let food: CatFood

    var body: some View {
        Image(food.assetName)
            .resizable()
            .scaledToFit()
            .frame(width: 74, height: 74)
        .shadow(color: .black.opacity(0.14), radius: 16, y: 8)
    }
}

#Preview {
    let needsViewModel = CatNeedsViewModel()
    needsViewModel.loadPreview(hunger: 32, cleanliness: 88)

    return HomeView()
        .environment(needsViewModel)
}
