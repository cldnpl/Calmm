import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var cats: [CatModel]

    @State private var rootViewModel = RootViewModel()
    @State private var needsViewModel = CatNeedsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            currentTabView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !shouldHideTabBar {
                CustomTabBar(selectedTab: $rootViewModel.selectedTab)
            }
        }
        .environment(needsViewModel)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            ensureCatExists()
            connectNeedsIfPossible()
        }
        .onChange(of: cats.count) {
            connectNeedsIfPossible()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                ensureCatExists()
                connectNeedsIfPossible()
            }

            needsViewModel.handleScenePhase(newPhase)
        }
    }

    private var shouldHideTabBar: Bool {
        rootViewModel.selectedTab == .home && needsViewModel.isFeedingModeActive
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch rootViewModel.selectedTab {
        case .games:
            MinigameSelectView()
        case .shop:
            ShopView()
        case .home:
            HomeView()
        case .style:
            StyleView()
        case .profile:
            ProfileView()
        }
    }

    private func ensureCatExists() {
        guard cats.isEmpty else { return }

        modelContext.insert(CatModel())
        try? modelContext.save()
    }

    private func connectNeedsIfPossible() {
        guard let cat = cats.first else { return }
        needsViewModel.connect(modelContext: modelContext, cat: cat)
    }
}

#Preview {
    RootView()
        .modelContainer(for: CatModel.self, inMemory: true)
}
