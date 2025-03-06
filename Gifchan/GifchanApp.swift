//
//  GifchanApp.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

@main
struct GifchanApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    setAppIconBasedOnTheme()
                }
        }
    }
}

func setAppIconBasedOnTheme() {
    guard UIApplication.shared.supportsAlternateIcons else { return }
    
    let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    let iconName = isDarkMode ? "AppIconDark" : nil

    UIApplication.shared.setAlternateIconName(iconName) { error in
        if let error = error {
            print("Помилка зміни іконки: \(error.localizedDescription)")
        }
    }
}
