import SwiftUI

struct NeedProgressBar: View {
    let title: String
    let systemImage: String
    let value: Double
    let tint: Color
    let trackTint: Color

    private var clampedValue: Double {
        min(max(value, 0), 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tint)

                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "FFF3E8"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.16))
                )
                .shadow(color: .black.opacity(0.14), radius: 3, y: 1)

                Spacer()

                Text("\(Int(clampedValue.rounded()))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "FDE5D6"))
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(trackTint.opacity(0.55))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.82), tint, tint.opacity(0.92)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (clampedValue / 100))
                        .shadow(color: tint.opacity(0.22), radius: 4, y: 2)
                }
            }
            .frame(height: 10)
            .animation(.linear(duration: 0.9), value: clampedValue)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "6E4638")
            .ignoresSafeArea()

        NeedProgressBar(
            title: "Hunger",
            systemImage: "fork.knife",
            value: 76,
            tint: Color(hex: "F0997B"),
            trackTint: Color(hex: "5B382D")
        )
        .padding(20)
    }
}
