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
                        text: "Savings",
                        img: "star.fill",
                        process: { isFavorite = false }
                    )
                }
                .padding()
                if isFavorite {
                    FavoritesView()
                }else{
//                    MadeView()
                }
            }
            .navigationTitle("Savings")
        }
    }
    
    func buttonForSaving(isSelected: Bool, text: String, img: String, process: @escaping () -> Void) -> some View {
        Button(action: process) {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.black : Color.clear) // 🔥 Заповнює чорним, якщо вибрано
                .frame(height: 50)
                .overlay(
                    Label(text, systemImage: img)
                        .foregroundColor(isSelected ? .white : .black) // 🔥 Білий текст, якщо вибрано
                        .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2) // 🔥 Чорний контур
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected) // 🔥 Анімація зміни стану
        }
        .padding(5)
    }
}
