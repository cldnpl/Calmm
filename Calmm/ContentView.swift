//
//  ContentView.swift
//  Calmm
//
//  Created by Claudia Napolitano on 30/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CatModel.self, inMemory: true)
}
