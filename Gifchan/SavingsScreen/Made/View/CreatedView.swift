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
                        ForEach(createdGifs.sorted(by: { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }), id: \..id) { gif in
                            NavigationLink(destination: GifDetailView(gifData: gif.data)) {
                                LongPressToDeleteView(gif: gif, deleteAction: deleteGif)
                                    .contentShape(Rectangle())
                            }
                        }
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
    
    private func deleteGif(_ gif: CreatedGif) {
        CoreDataManager.shared.removeFromCreatedGifs(gif)
        createdGifs = CoreDataManager.shared.fetchCreatedGifs()
    }
}

struct LongPressToDeleteView: View {
    let gif: CreatedGif
    let deleteAction: (CreatedGif) -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        GifImageView(gifData: gif.data, gifURL: nil)
            .frame(maxHeight: 400)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            .contentShape(Rectangle())
            .onLongPressGesture {
                showDeleteAlert = true
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete GIF"),
                    message: Text("Are you sure you want to delete this GIF?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAction(gif)
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}
