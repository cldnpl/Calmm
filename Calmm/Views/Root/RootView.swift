import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var cats: [CatModel]

    @StateObject private var rootViewModel = RootViewModel()
    @StateObject private var needsViewModel = CatNeedsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            currentTabView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $rootViewModel.selectedTab)
        }
        .environmentObject(needsViewModel)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            ensureCatExists()
            connectNeedsIfPossible()
        }
        .onChange(of: cats.count) { _ in
            connectNeedsIfPossible()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                ensureCatExists()
                connectNeedsIfPossible()
            }

            needsViewModel.handleScenePhase(newPhase)
        }
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch rootViewModel.selectedTab {
        case .games:
            GamesView()
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
