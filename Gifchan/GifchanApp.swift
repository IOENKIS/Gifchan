//
//  GifchanApp.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

@main
struct GifchanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
