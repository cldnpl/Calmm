//
//  ContentView.swift
//  Calmm
//
//  Created by Claudia Napolitano on 30/03/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            Text("Games")
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            Text("Shop")
                .tabItem {
                    Label("Shop", systemImage: "bag.fill")
                }
            Text("Style")
                .tabItem {
                    Label("Style", systemImage: "tshirt.fill")
                }
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "star.fill")
                }
        }
    }
}
