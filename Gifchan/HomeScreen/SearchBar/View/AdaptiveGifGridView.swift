//
//  AdaptiveGifGridView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 05.03.2025.
//


import SwiftUI

struct AdaptiveGifGridView: View {
    let gifData: [GifData]
    let spacing: CGFloat
    let columns: Int

    var body: some View {
        let gifSize = getGifSize()

        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(gifData, id: \.id) { gif in
                    NavigationLink(destination: GifDetailView(gifURL: gif.images.fixedHeight.url)) {
                        GifImageView(gifURL: gif.images.fixedHeight.url)
                            .frame(width: gifSize, height: gifSize)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, spacing)
        }
    }

    private func getGifSize() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = spacing * CGFloat(columns + 1)
        return (screenWidth - totalSpacing) / CGFloat(columns)
    }
}
