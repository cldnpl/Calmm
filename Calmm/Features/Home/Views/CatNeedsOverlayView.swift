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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
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
