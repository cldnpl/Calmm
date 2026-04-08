import SwiftUI

struct PlaceholderTabView: View {
    let title: String

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(hex: "FFF3E8"))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
    }
}

#Preview {
    PlaceholderTabView(title: "Preview")
}
