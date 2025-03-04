//
//  GifView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifView: View {
    @StateObject var viewModel = GifViewModel()
    @State private var isRotating = false
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                isRotating.toggle()
                            }
                            viewModel.refreshGifs()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                isRotating = false
                            }
                        }) {
                            Image(systemName: "arrow.trianglehead.clockwise")
                                .foregroundStyle(.stroke)
                                .rotationEffect(.degrees(isRotating ? 360 : 0))
                        }
                    }
                }
            }
        }
    }
}
