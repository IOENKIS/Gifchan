//
//  GifImageView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI
import UIKit

struct GifImageView: UIViewRepresentable {
    let gifURL: String
    static let cache = NSCache<NSString, NSData>()

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let cachedData = GifImageView.cache.object(forKey: gifURL as NSString),
           let gifImage = UIImage.gif(data: cachedData as Data) {
            uiView.image = gifImage
            return
        }

        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: self.gifURL), let gifData = try? Data(contentsOf: url) else {
                print("❌ Помилка завантаження GIF за URL: \(self.gifURL)")
                return
            }

            DispatchQueue.main.async {
                if let gifImage = UIImage.gif(data: gifData) {
                    GifImageView.cache.setObject(gifData as NSData, forKey: self.gifURL as NSString)
                    uiView.image = gifImage
                }
            }
        }
    }
}
