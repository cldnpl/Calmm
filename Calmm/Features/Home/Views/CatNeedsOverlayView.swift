import SwiftUI

struct CatNeedsOverlayView: View {
    let hunger: Double
    let cleanliness: Double

    var body: some View {
        VStack(spacing: 10) {
            NeedProgressBar(
                title: "Hunger",
                systemImage: "fork.knife",
                value: hunger,
                tint: Color(hex: "F0997B"),
                trackTint: Color(hex: "6E4638")
            )

            NeedProgressBar(
                title: "Cleanliness",
                systemImage: "sparkles",
                value: cleanliness,
                tint: Color(hex: "D85A30"),
                trackTint: Color(hex: "5B382D")
            )
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.35)
            .ignoresSafeArea()

        CatNeedsOverlayView(hunger: 72, cleanliness: 88)
            .padding(20)
    }
}
