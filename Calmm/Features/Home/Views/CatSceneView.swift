import SwiftUI

struct CatSceneView<CatGesture: Gesture>: View {
    let imageName: String
    let accessoryImageNames: [String]
    let catGesture: CatGesture
    let isInteractionEnabled: Bool
    let onCatFrameChange: (CGRect) -> Void

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

                ZStack {
                    Image(imageName)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: catSize, height: catSize)
                        .rotationEffect(.degrees(90))

                    ForEach(Array(accessoryImageNames.enumerated()), id: \.offset) { _, accessoryImageName in
                        Image(accessoryImageName)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: catSize, height: catSize)
                            .rotationEffect(.degrees(90))
                            .allowsHitTesting(false)
                    }
                }
                .offset(y: catVerticalOffset)
                .background {
                    GeometryReader { proxy in
                        let frame = proxy.frame(in: .named("home-space"))

                        Color.clear
                            .onAppear {
                                onCatFrameChange(frame)
                            }
                            .onChange(of: frame) { _, newFrame in
                                onCatFrameChange(newFrame)
                            }
                    }
                }
                .contentShape(Rectangle())
                .gesture(catGesture)
                .allowsHitTesting(isInteractionEnabled)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

#Preview {
    CatSceneView(
        imageName: "TailUp",
        accessoryImageNames: ["Jacketgrif", "Glassblue", "Froghat"],
        catGesture: TapGesture(),
        isInteractionEnabled: true,
        onCatFrameChange: { _ in }
    )
}
