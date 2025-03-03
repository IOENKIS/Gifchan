//
//  ContentView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifView: View {
    let prompts: [String] = ["trends", "cats and dogs", "memes"]
    @ObservedObject var viewModel = GifViewModel()
    var body: some View {
        NavigationView {
            VStack{
                ScrollView(){
                    ForEach(prompts, id: \.self) { prompt in
                        GifSectionView(title: prompt, gifURLs: viewModel.gifURLs[prompt] ?? [])
                    }
                }
            }
            .navigationTitle("Gifchan GIF's")
            .onAppear {
                viewModel.fetchAllGifURLs(prompts: prompts)
            }
        }
    }
}

// Окремий компонент для кожного ряду GIF
struct GifSectionView: View {
    let title: String
    let gifURLs: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title.capitalized)
                .font(.headline)
                .padding([.bottom, .leading], 10)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(gifURLs, id: \.self) { url in
                            GifImageView(gifURL: url)
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 2)
                    .fill(Color.black)
            )
            .padding(10)
            .frame(height: 150)
        }
        .padding(.vertical, 20)
    }
}
