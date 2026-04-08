import SwiftUI

struct StyleView: View {
    @Environment(CatNeedsViewModel.self) private var needsViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("wardrobeBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    Spacer(minLength: 0)

                    wardrobeCard(maxWidth: geometry.size.width - 32)

                    WardrobeCatPreview(accessoryImageNames: needsViewModel.equippedAccessoryAssetNames)
                        .frame(
                            width: min(geometry.size.width * 0.92, 380),
                            height: min(geometry.size.width * 1.15, 460)
                        )
                        .offset(y: 14)

                    Spacer(minLength: 100)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    private func wardrobeCard(maxWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            if needsViewModel.ownedAccessories.isEmpty {
                Text("Buy clothes in the shop first.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "866458"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 36)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 14) {
                        ForEach(needsViewModel.ownedAccessories) { accessory in
                            WardrobeAccessoryItem(accessory: accessory)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(width: maxWidth)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.88), lineWidth: 1)
        )
        .frame(height: needsViewModel.ownedAccessories.isEmpty ? 92 : 180)
        .shadow(color: .black.opacity(0.1), radius: 18, y: 10)
    }
}

private struct WardrobeAccessoryItem: View {
    @Environment(CatNeedsViewModel.self) private var needsViewModel

    let accessory: CatAccessory

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: "FFF7F1"))
                    .frame(width: 82, height: 82)

                Image(accessory.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(accessory.previewRotationDegrees))
            }

            Text(accessory.name)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "513329"))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 92)

            Button(isEquipped ? "Unwear" : "Wear") {
                if isEquipped {
                    needsViewModel.unequipAccessory(id: accessory.id)
                } else {
                    needsViewModel.equipAccessory(id: accessory.id)
                }
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: "D97B5D"))
            .clipShape(Capsule())
            .buttonStyle(.plain)
        }
        .frame(width: 98)
    }

    private var isEquipped: Bool {
        needsViewModel.isAccessoryEquipped(accessory.id)
    }
}

private struct WardrobeCatPreview: View {
    let accessoryImageNames: [String]

    var body: some View {
        ZStack {
            Image("TailUp")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .rotationEffect(.degrees(90))

            ForEach(Array(accessoryImageNames.enumerated()), id: \.offset) { _, accessoryImageName in
                Image(accessoryImageName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(90))
                    .allowsHitTesting(false)
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 18, y: 10)
    }
}

#Preview {
    let needsViewModel = CatNeedsViewModel()
    needsViewModel.loadPreview(hunger: 76, cleanliness: 88)

    return StyleView()
        .environment(needsViewModel)
}
