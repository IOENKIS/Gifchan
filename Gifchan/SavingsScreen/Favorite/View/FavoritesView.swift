//
//  FavoritesView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//


import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [FavoriteGif] = []

    var body: some View {
        VStack {
            if favorites.isEmpty {
                Text("No favorite GIFs yet 😢")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack {
                        ForEach(favorites, id: \.self) { gif in
                            GifImageView(gifURL: gif.url ?? "")
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            favorites = CoreDataManager.shared.fetchFavorites()
        }
    }
}
