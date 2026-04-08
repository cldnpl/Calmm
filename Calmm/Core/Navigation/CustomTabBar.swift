import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.iconName)
                            .font(tab.isCenterTab ? .title2 : .system(size: 20))
                            .scaleEffect(isSelected && !tab.isCenterTab ? 1.15 : 1.0)
                            .offset(y: isSelected && !tab.isCenterTab ? -2 : 0)

                        if !tab.isCenterTab {
                            Text(tab.title)
                                .font(.system(size: 10, weight: .medium))
                                .opacity(isSelected ? 1 : 0.4)
                        }
                    }
                    .foregroundStyle(
                        tab.isCenterTab
                            ? .white
                            : (isSelected ? Color(hex: "D85A30") : Color.gray.opacity(0.6))
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, tab.isCenterTab ? 12 : 8)
                    .padding(.horizontal, tab.isCenterTab ? 14 : 0)
                    .background(
                        tab.isCenterTab
                            ? Color(hex: isSelected ? "C9623E" : "F0997B")
                            : (isSelected ? Color(hex: "F0997B").opacity(0.12) : Color.clear)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: tab.isCenterTab ? 22 : 16))
                    .offset(y: tab.isCenterTab ? -16 : 0)
                    .shadow(color: tab.isCenterTab ? Color(hex: "F0997B").opacity(0.35) : .clear,
                            radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .padding(.top, 10)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 20, y: -4)
        )
        .padding(.horizontal, 16)
    }
}

private struct CustomTabBarPreviewContainer: View {
    @State private var selectedTab: AppTab = .shop

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "FFF3E8")
                .ignoresSafeArea()

            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    CustomTabBarPreviewContainer()
}
