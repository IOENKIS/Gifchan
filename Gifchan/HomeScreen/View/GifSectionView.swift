//
//  GifSectionView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifSectionView: View {
    let title: String
    let gifURLs: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title.capitalized)
                .font(.headline)
                .padding([.leading, .vertical], 10)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if gifURLs.isEmpty {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 150, height: 200)
                                    .shadow(radius: 5)
                                    .redacted(reason: .placeholder)
                            }
                        } else {
                            ForEach(gifURLs, id: \.self) { url in
                                GifImageView(gifURL: url)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 2)
                    .fill(Color.stroke)
            )
            .padding(10)
            .frame(height: 200)
        }
        .padding(.vertical, 15)
        .onDisappear {
            GifImageView.cache.removeAllObjects()
        }
    }
}
