//
//  CalmmApp.swift
//  Calmm
//
//  Created by Claudia Napolitano on 30/03/26.
//

import SwiftUI
import SwiftData

@main
struct CalmmApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: CatModel.self)
    }
}
