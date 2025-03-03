//
//  GifView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifView: View {
    @StateObject var viewModel = GifViewModel()
    var body: some View {
        NavigationView {
            ZStack{
                Color.background.ignoresSafeArea()
                VStack{
                    ScrollView(){
                        ForEach(viewModel.prompts, id: \.self) { prompt in
                            GifSectionView(title: prompt, gifURLs: viewModel.gifURLs[prompt] ?? [])
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 20)
                .navigationTitle("Gifchan GIF's")
            }
        }
    }
}
