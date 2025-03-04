//
//  GifViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//


import Foundation

class GifViewModel: ObservableObject{
    @Published var gifURLs: [String: [String]] = [:]
    let prompts: [String] = ["most popular", "animals", "memes", "programming"]
    let apiKey = "dmes1vSx87yb6L9oyhCvhF9ZCipRdMPx"
    
    init() {
        fetchAllGifURLs()
    }
    
    func fetchGifURLs(query: String, limit: Int = 10, completion: @escaping ([String]) -> Void) {
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(query)&limit=\(limit)&offset=\(Int.random(in: 0..<200))&rating=g"
        guard let url = URL(string: urlString) else {
            print("❌ Помилка формування API-запиту")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Помилка отримання даних: \(error?.localizedDescription ?? "невідома помилка")")
                completion([])
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(GifResponse.self, from: data)
                let gifURLs = decodedResponse.data.compactMap { $0.images.fixedHeight.url }

                if gifURLs.isEmpty {
                    print("⚠️ API повернуло порожній список GIF-URL")
                } else {
                    print("✅ Отримано \(gifURLs.count) GIF-URL")
                }

                completion(gifURLs)
            } catch {
                print("❌ Помилка парсингу JSON: \(error)")
                completion([])
            }
        }

        task.resume()
    }

    func fetchAllGifURLs() {
        for prompt in prompts {
            fetchGifURLs(query: prompt) { urls in
                DispatchQueue.main.async {
                    self.gifURLs[prompt] = urls
                    print("🎯 Отримані GIF для '\(prompt)': \(urls)")
                }
            }
        }
    }
    
    func refreshGifs() {
        gifURLs.removeAll()
        fetchAllGifURLs()
    }
}
