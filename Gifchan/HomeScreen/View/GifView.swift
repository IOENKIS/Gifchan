//
//  GifView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifView: View {
    @StateObject var viewModel = GifViewModel()
    @StateObject var searchBarViewModel = SearchBarViewModel()
    @State private var isRotating = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                VStack {
                    SearchBarView(searchText: $searchBarViewModel.searchText, onTapAction: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            searchBarViewModel.startSearch()
                        }
                    })
                    .padding(.horizontal, 20)

                    ZStack {
                        if searchBarViewModel.isSearching || searchBarViewModel.searchText != "" {
                            SearchResultsView(viewModel: searchBarViewModel, isSearching: $searchBarViewModel.isSearching)
                                .transition(.opacity)
                        } else {
                            ScrollView {
                                ForEach(searchBarViewModel.filteredPrompts, id: \.self) { prompt in
                                    GifSectionView(title: prompt, gifURLs: viewModel.gifURLs[prompt] ?? [])
                                }
                            }
                            .transition(.opacity)
                        }
                    }
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
        .onAppear {
            searchBarViewModel.gifViewModel = viewModel
        }
    }
}
