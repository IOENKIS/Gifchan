//
//  MainView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 1
    var body: some View {
        TabView(selection: $selectedTab){
            EditorView()
                .tabItem {
                    Label("Editor", systemImage: "pencil")
                        .font(.title)
                        .foregroundStyle(.black)
                }
                .tag(0)
            GifView()
                .tabItem {
                    Label("GIFs", systemImage: "photo.on.rectangle.angled")
                        .font(.title)
                        .foregroundStyle(.black)
                }
                .tag(1)
            SavingsView()
                .tabItem {
                    Label("Savings", systemImage: "square.and.arrow.down")
                        .font(.title)
                        .foregroundStyle(.black)
                }
                .tag(2)
        }
    }
}

