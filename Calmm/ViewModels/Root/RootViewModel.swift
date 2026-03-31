import Combine
import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
}
