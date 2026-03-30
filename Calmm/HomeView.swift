import SwiftUI
import Combine
import SpriteKit

struct HomeView: View {
    // 1. This "State" tells the app which image to show
    @State private var isTailUp = false
    
    // 2. This creates a "heartbeat" for your animation
    let animationTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Spacer()
            
            Text("Pet Status: Happy")
                .font(.headline)
                .padding()

            // 3. Modifiers are applied top-to-bottom
            Image(isTailUp ? "Tailup" : "Taildown")
                .interpolation(.none) // Apply this first while it's still an 'Image'
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .rotationEffect(.degrees(90))
            
            Spacer()
            
           
        }
        // 4. Listen for the timer
        .onReceive(animationTimer) { _ in
            isTailUp.toggle()
        }
    }
}

#Preview {
    HomeView() // Fixed the casing here
}
