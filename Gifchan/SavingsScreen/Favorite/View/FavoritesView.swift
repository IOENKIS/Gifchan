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
                Spacer()
                Text("No favorite GIFs yet 😢")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack {
                        favoriteGifList
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

    private var favoriteGifList: some View {
        ForEach(favorites, id: \ .id) { gif in
            NavigationLink(destination: GifDetailView(gifData: gif.data, gifURL: gif.url)) {
                GifImageView(gifData: gif.data, gifURL: gif.url)
                    .frame(maxHeight: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
            }
        }
    }
}
