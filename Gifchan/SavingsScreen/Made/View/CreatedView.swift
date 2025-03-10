//
//  CreatedView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 04.03.2025.
//

import SwiftUI

struct CreatedView: View {
    @State private var createdGifs: [CreatedGif] = []
    
    var body: some View {
        VStack {
            if createdGifs.isEmpty {
                Spacer()
                Text("No created GIFs yet 😢")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack {
                        createdGifList
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Created")
        .onAppear {
            createdGifs = CoreDataManager.shared.fetchCreatedGifs()
        }
    }
    
    private var createdGifList: some View {
        ForEach(createdGifs.sorted(by: { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }), id: \.id) { gif in
            if let gifURL = gif.url {
                NavigationLink(destination: GifDetailView(gifURL: gifURL)) {
                    GifImageView(gifURL: gifURL)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                }
            }
        }
    }
}
