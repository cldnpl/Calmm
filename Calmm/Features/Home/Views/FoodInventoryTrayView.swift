import SwiftUI

struct FoodInventoryTrayView: View {
    let foods: [CatFoodInventoryEntry]
    let activeFoodID: String?
    let onDragChanged: (CatFoodInventoryEntry, CGPoint) -> Void
    let onDragEnded: (CatFoodInventoryEntry, CGPoint) -> Void

    @State private var wheelRotation: Double = 0
    @State private var rotationAtDragStart: Double?

    private let itemAngleSpacing = 26.0

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let wheelDiameter = max(size.width * 1.08, 340)
            let wheelRadius = wheelDiameter / 2
            let wheelCenter = CGPoint(
                x: size.width / 2,
                y: size.height + 28
            )
            let itemRadius = wheelRadius - 68

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "FFF8F1").opacity(0.98),
                                Color(hex: "F7DCCB").opacity(0.9)
                            ],
                            center: .center,
                            startRadius: 18,
                            endRadius: wheelRadius
                        )
                    )
                    .frame(width: wheelDiameter, height: wheelDiameter)
                    .position(wheelCenter)
                    .shadow(color: .black.opacity(0.12), radius: 20, y: 8)

                Circle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
                    .frame(width: wheelDiameter, height: wheelDiameter)
                    .position(wheelCenter)

                Circle()
                    .stroke(Color(hex: "DFA487").opacity(0.45), lineWidth: 2)
                    .frame(width: wheelDiameter - 48, height: wheelDiameter - 48)
                    .position(wheelCenter)

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(wheelScrollGesture)

                if foods.isEmpty {
                    Text("No food in inventory")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "7D5A4E"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 26)
                } else {
                    ForEach(Array(foods.enumerated()), id: \.element.id) { index, entry in
                        FoodWheelItemView(
                            entry: entry,
                            isHidden: activeFoodID == entry.id,
                            onDragChanged: { point in
                                onDragChanged(entry, point)
                            },
                            onDragEnded: { point in
                                onDragEnded(entry, point)
                            }
                        )
                        .position(
                            point(
                                for: index,
                                count: foods.count,
                                center: wheelCenter,
                                radius: itemRadius
                            )
                        )
                    }
                }
            }
            .padding(.top, 30)
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 188)
    }

    private var wheelScrollGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                if rotationAtDragStart == nil {
                    rotationAtDragStart = wheelRotation
                }

                let baseRotation = rotationAtDragStart ?? wheelRotation
                wheelRotation = baseRotation + Double(value.translation.width) * 0.22
            }
            .onEnded { _ in
                rotationAtDragStart = nil
            }
    }

    private func point(for index: Int, count: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let centeredIndex = Double(index) - Double(count - 1) / 2
        let angle = -90.0 + (centeredIndex * itemAngleSpacing) + wheelRotation
        let radians = angle * .pi / 180

        return CGPoint(
            x: center.x + CGFloat(cos(radians)) * radius,
            y: center.y + CGFloat(sin(radians)) * radius
        )
    }
}

private struct FoodWheelItemView: View {
    let entry: CatFoodInventoryEntry
    let isHidden: Bool
    let onDragChanged: (CGPoint) -> Void
    let onDragEnded: (CGPoint) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(entry.food.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 124, height: 124)
                .shadow(color: .black.opacity(0.16), radius: 8, y: 4)

            Text("x\(entry.count)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "D85A30"))
                .clipShape(Capsule())
                .offset(x: 10, y: -8)
        }
        .frame(width: 136, height: 136)
        .contentShape(Circle())
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
                CatFoodInventoryEntry(food: CatFoodCatalog.dryfish, count: 1),
                CatFoodInventoryEntry(food: CatFoodCatalog.donut, count: 3),
                CatFoodInventoryEntry(food: CatFoodCatalog.fishfood, count: 4)
            ],
            activeFoodID: nil,
            onDragChanged: { _, _ in },
            onDragEnded: { _, _ in }
        )
        .padding(.bottom, 16)
    }
    .coordinateSpace(name: "home-space")
}
