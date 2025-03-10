//
//  SavingsView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct SavingsView: View {
    @State private var isFavorite = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    buttonForSaving(
                        isSelected: isFavorite,
                        text: "Favorites",
                        img: "heart.fill",
                        process: { isFavorite = true }
                    )

                    buttonForSaving(
                        isSelected: !isFavorite,
                        text: "Created",
                        img: "star.fill",
                        process: { isFavorite = false }
                    )
                }
                .padding()
                if isFavorite {
                    FavoritesView()
                }else{
                    CreatedView()
                }
            }
            .navigationTitle("Savings")
        }
    }
    
    func buttonForSaving(isSelected: Bool, text: String, img: String, process: @escaping () -> Void) -> some View {
        Button(action: process) {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.stroke : Color.clear)
                .frame(height: 50)
                .overlay(
                    Label(text, systemImage: img)
                        .foregroundColor(isSelected ? .background : .stroke)
                        .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.stroke, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .padding(5)
    }
}
