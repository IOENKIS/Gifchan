//
//  SearchBarViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 05.03.2025.
//

import SwiftUI
import Combine

class SearchBarViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            searchGifs()
        }
    }
    @Published var isSearching: Bool = false
    @Published var trendingSearches: [String] = []
    @Published var searchResults: [GifData] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let apiKey = "dmes1vSx87yb6L9oyhCvhF9ZCipRdMPx"

    var filteredPrompts: [String] {
        guard let viewModel = gifViewModel else { return [] }
        if searchText.isEmpty {
            return viewModel.prompts
        } else {
            return viewModel.prompts.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    weak var gifViewModel: GifViewModel?
    
    init() {
        fetchTrendingSearches()
    }
    
    init(gifViewModel: GifViewModel? = nil) {
        self.gifViewModel = gifViewModel
    }
    
    func fetchTrendingSearches() {
            guard let url = URL(string: "https://api.giphy.com/v1/trending/searches?api_key=\(apiKey)") else {
                print("❌ Помилка: некоректний URL")
                return
            }

            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: TrendingSearchResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Помилка отримання трендових пошуків: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] response in
                    self?.trendingSearches = response.data
                })
                .store(in: &cancellables)
        }
    
    func searchGifs() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        guard let url = URL(string: "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&limit=20") else {
            print("❌ Некоректний URL для пошуку GIF")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GifResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ Помилка отримання GIF: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                self?.searchResults = response.data
            })
            .store(in: &cancellables)
    }

    func startSearch() {
        isSearching = true
    }

    func cancelSearch() {
        searchText = ""
        isSearching = false
    }
}
