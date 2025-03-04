//
//  GifDetailView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifDetailView: View {
    let gifURL: String
    @State private var isFavorite = false
    @State private var isReference = false

    var body: some View {
        VStack {
            GifImageView(gifURL: gifURL)
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 10)
                .padding()

            VStack(spacing: 20) {
                Button(action: {
                    isFavorite.toggle()
                    if isFavorite {
                        CoreDataManager.shared.addToFavorites(gifURL: gifURL)
                    } else {
                        CoreDataManager.shared.removeFromFavorites(gifURL: gifURL)
                    }
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isFavorite ? Color.black : Color.clear)
                        .frame(height: 50)
                        .overlay(
                            Label("Add to Favorite", systemImage: isFavorite ? "star.fill" : "star")
                                .foregroundColor(isFavorite ? .white : .black)
                                .padding()
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFavorite)
                }

                Button(action: {
                    isReference.toggle()
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isReference ? Color.black : Color.clear)
                        .frame(height: 50)
                        .overlay(
                            Label("Take as Reference", systemImage: "pencil")
                                .foregroundColor(isReference ? .white : .black)
                                .padding()
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isReference)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("GIF Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkIfFavorite()
        }
    }

    private func checkIfFavorite() {
        isFavorite = CoreDataManager.shared.isGifFavorite(gifURL: gifURL)
    }
}
