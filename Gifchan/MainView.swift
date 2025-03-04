//
//  MainView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            EditorView()
                .tabItem {
                    Label("Editor", systemImage: "pencil")
                        .font(.title)
                        .foregroundStyle(.black)
                }
            GifView()
                .tabItem {
                    Label("GIFs", systemImage: "photo.on.rectangle.angled")
                        .font(.title)
                        .foregroundStyle(.black)
                }
            SavingsView()
                .tabItem {
                    Label("Savings", systemImage: "square.and.arrow.down")
                        .font(.title)
                        .foregroundStyle(.black)
                }
        }
    }
}

// Порожні вкладки для демонстрації
struct EditorView: View {
    var body: some View {
        Text("Favorites")
            .font(.largeTitle)
            .navigationTitle("Favorites")
    }
}
