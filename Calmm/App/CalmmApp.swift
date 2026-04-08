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
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: CatModel.self)
        } catch {
            // Schema changed after merge — wipe old store and retry
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            for ext in ["store", "store-wal", "store-shm"] {
                let url = appSupport.appending(path: "default.\(ext)")
                try? FileManager.default.removeItem(at: url)
            }
            modelContainer = try! ModelContainer(for: CatModel.self)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
