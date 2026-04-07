import SwiftUI

struct FoodInventoryTrayView: View {
    let foods: [CatFoodInventoryEntry]
    let activeFoodID: String?
    let onDragChanged: (CatFoodInventoryEntry, CGPoint) -> Void
    let onDragEnded: (CatFoodInventoryEntry, CGPoint) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.white.opacity(0.55))
                .frame(width: 52, height: 5)

            if foods.isEmpty {
                Text("No food in inventory")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "7D5A4E"))
                    .padding(.vertical, 20)
            } else {
                HStack(spacing: 12) {
                    ForEach(foods) { entry in
                        FoodInventoryItemView(
                            entry: entry,
                            isHidden: activeFoodID == entry.id,
                            onDragChanged: { point in
                                onDragChanged(entry, point)
                            },
                            onDragEnded: { point in
                                onDragEnded(entry, point)
                            }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(hex: "FFF8F1").opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.82), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, y: -4)
    }
}

private struct FoodInventoryItemView: View {
    let entry: CatFoodInventoryEntry
    let isHidden: Bool
    let onDragChanged: (CGPoint) -> Void
    let onDragEnded: (CGPoint) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 76, height: 76)

                Image(entry.food.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)

                Text("x\(entry.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "D85A30"))
                    .clipShape(Capsule())
                    .offset(x: 8, y: -8)
            }

            Text(entry.food.name)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "5A392D"))
        }
        .opacity(isHidden ? 0.12 : 1)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("home-space"))
                .onChanged { value in
                    onDragChanged(value.location)
                }
                .onEnded { value in
                    onDragEnded(value.location)
                }
        )
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(hex: "FFF3E8")
            .ignoresSafeArea()

        FoodInventoryTrayView(
            foods: [
                CatFoodInventoryEntry(food: CatFoodCatalog.milk, count: 2),
                CatFoodInventoryEntry(food: CatFoodCatalog.dryfish, count: 1)
            ],
            activeFoodID: nil,
            onDragChanged: { _, _ in },
            onDragEnded: { _, _ in }
        )
        .padding()
    }
    .coordinateSpace(name: "home-space")
}
