import SwiftUI

struct ShopView: View {
    @Environment(CatNeedsViewModel.self) private var needsViewModel

    @State private var expandedSection: ShopSection.ID?
    @State private var showInsufficientCoinsAlert = false

    private let sections: [ShopSection] = [
        ShopSection(
            title: "CLOTHES",
            subtitle: "Dress up your cat",
            iconName: "tshirt.fill",
            accentColorHex: "D97B5D",
            items: [
                ShopItem(name: "Cloth 1", price: 120, symbolName: "tshirt.fill"),
                ShopItem(name: "Cloth 2", price: 180, symbolName: "bag.fill"),
                ShopItem(name: "Cloth 3", price: 220, symbolName: "tag.fill"),
                ShopItem(name: "Cloth 4", price: 260, symbolName: "tag.fill")
            ]
        ),
        ShopSection(
            title: "FOOD",
            subtitle: "Snacks and treats",
            iconName: "carrot.fill",
            accentColorHex: "E4A64B",
            items: [
                ShopItem(name: "Milk", price: 20, assetName: "Milk"),
                ShopItem(name: "Donut", price: 35, assetName: "Donut"),
                ShopItem(name: "Dryfish", price: 45, assetName: "Dryfish"),
                ShopItem(name: "Fishfood", price: 30, assetName: "Fishfood")
            ]
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.08),
                        Color(hex: "FFF3E8").opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 0)

                        shopContent

                        Spacer(minLength: 0)
                    }
                    .frame(
                        minHeight: geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 128
                    )
                    .frame(maxWidth: .infinity)
                }
                .safeAreaPadding(.top, 12)
                .safeAreaPadding(.bottom, 116)
            }
        }
        .alert("non hai abbastanza monete", isPresented: $showInsufficientCoinsAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private var shopContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerView

            ForEach(sections) { section in
                ShopExpandableSection(
                    section: section,
                    isExpanded: expandedSection == section.id,
                    onBuy: { item in
                        handlePurchase(of: item)
                    },
                    onToggle: {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                            expandedSection = expandedSection == section.id ? nil : section.id
                        }
                    }
                )
            }
        }
        .frame(maxWidth: 340)
        .padding(.horizontal, 30)
        .padding(.trailing, 50)
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shop")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(hex: "5C3427"))

            Text("Time to go shopping!")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "7D5A4E"))

            coinBadge
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.65), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
    }

    private var coinBadge: some View {
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
                .fill(Color(hex: "FFF8F1"))
        )
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.75), lineWidth: 1)
        )
    }

    private func handlePurchase(of item: ShopItem) {
        if !needsViewModel.spendCoins(item.price) {
            showInsufficientCoinsAlert = true
        }
    }
}

private struct ShopExpandableSection: View {
    let section: ShopSection
    let isExpanded: Bool
    let onBuy: (ShopItem) -> Void
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: section.accentColorHex).opacity(0.18))
                            .frame(width: 52, height: 52)

                        Image(systemName: section.iconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(hex: section.accentColorHex))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "4D2F26"))

                        Text(section.subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "866458"))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: section.accentColorHex))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white.opacity(0.9))
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(section.items) { item in
                        ShopItemRow(
                            item: item,
                            accentColorHex: section.accentColorHex,
                            onBuy: {
                                onBuy(item)
                            }
                        )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 14)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
    }
}

private struct ShopItemRow: View {
    let item: ShopItem
    let accentColorHex: String
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            itemArtwork

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "513329"))

                Text("\(item.price) coins")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: "8A6A5B"))
            }

            Spacer()

            Button(action: onBuy) {
                Text("Buy")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color(hex: accentColorHex))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: "FFF8F1"))
        )
    }

    @ViewBuilder
    private var itemArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .frame(width: 72, height: 72)

            if let assetName = item.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
            } else if let symbolName = item.symbolName {
                Image(systemName: symbolName)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(Color(hex: accentColorHex))
            }
        }
    }
}

private struct ShopSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let accentColorHex: String
    let items: [ShopItem]
}

private struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    var assetName: String?
    var symbolName: String?
}

#Preview {
    let needsViewModel = CatNeedsViewModel()
    needsViewModel.loadPreview(hunger: 76, cleanliness: 88)

    return ShopView()
        .environment(needsViewModel)
}

#Preview("Shop Section Expanded") {
    ZStack {
        Color(hex: "FFF3E8")
            .ignoresSafeArea()

        ShopExpandableSection(
            section: ShopSection(
                title: "CLOTHES",
                subtitle: "Dress up your cat",
                iconName: "tshirt.fill",
                accentColorHex: "D97B5D",
                items: [
                    ShopItem(name: "Cloth 1", price: 120, symbolName: "tshirt.fill"),
                    ShopItem(name: "Cloth 2", price: 180, symbolName: "bag.fill")
                ]
            ),
            isExpanded: true,
            onBuy: { _ in },
            onToggle: {}
        )
        .padding(20)
    }
}

#Preview("Shop Item Row") {
    ZStack {
        Color(hex: "FFF3E8")
            .ignoresSafeArea()

        ShopItemRow(
            item: ShopItem(name: "Milk", price: 20, assetName: "Milk"),
            accentColorHex: "E4A64B",
            onBuy: {}
        )
        .padding(20)
    }
}
