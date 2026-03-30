//
//  ContentView.swift
//  Calmm
//
//  Created by Claudia Napolitano on 30/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 2

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Games")
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(0)

            Text("Shop")
                .tabItem {
                    Label("Shop", systemImage: "bag.fill")
                }
                .tag(1)

            HomeView()
                .tabItem {
                    Label("Kennel", systemImage: "house.fill")
                }
                .tag(2)

            Text("Style")
                .tabItem {
                    Label("Style", systemImage: "tshirt.fill")
                }
                .tag(3)

            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "star.fill")
                }
                .tag(4)
        }
    }
}
