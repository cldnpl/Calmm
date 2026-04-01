import SwiftUI

struct CatSceneView<CatGesture: Gesture>: View {
    let imageName: String
    let catGesture: CatGesture

    var body: some View {
        GeometryReader { geometry in
            let catSize = min(geometry.size.width * 1.5, geometry.size.height * 0.82)
            let catVerticalOffset = geometry.size.height * 0.1999

            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                Image(imageName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: catSize, height: catSize)
                    .rotationEffect(.degrees(90))
                    .offset(y: catVerticalOffset)
                    .contentShape(Rectangle())
                    .gesture(catGesture)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

#Preview {
    CatSceneView(
        imageName: "TailUp",
        catGesture: TapGesture()
    )
}
