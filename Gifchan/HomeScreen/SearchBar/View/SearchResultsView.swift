//
//  SearchResultsView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 05.03.2025.
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var viewModel: SearchBarViewModel
    @Binding var isSearching: Bool
    
    let minWidth: CGFloat = 120
    let spacing: CGFloat = 5
    
    var body: some View {
        ZStack{
            Color.clear.ignoresSafeArea()
            VStack {
                suggesButtons
                results
            }
        }
    }
    
    private var suggesButtons: some View {
        ZStack {
            Text("Loading trending searches...")
                .foregroundColor(.stroke)
                .padding()
                .opacity(viewModel.trendingSearches.isEmpty ? 1 : 0)
                .offset(y: viewModel.trendingSearches.isEmpty ? 0 : -10)
                .animation(.easeInOut(duration: 0.3), value: viewModel.trendingSearches.isEmpty)

            ScrollView(.horizontal, showsIndicators: false){
                HStack {
                    ForEach(viewModel.trendingSearches, id: \.self) { suggestion in
                        SearchButtonView(text: suggestion, searchText: $viewModel.searchText)
                    }
                }
                .frame(height: 60)
            }
            .opacity(viewModel.trendingSearches.isEmpty ? 0 : 1)
            .offset(y: viewModel.trendingSearches.isEmpty ? 10 : 0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.trendingSearches.isEmpty)
        }
    }
    
    private var results: some View {
        GeometryReader { geometry in
            let columnsCount = max(Int(geometry.size.width / minWidth), 2)
            ScrollView {
                AdaptiveGifGridView(gifData: viewModel.searchResults, spacing: spacing, columns: columnsCount)
            }
        }
    }
}
