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
    static let cache = NSCache<NSString, UIImage>()

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let cachedImage = GifImageView.cache.object(forKey: gifURL as NSString) {
            uiView.image = cachedImage
            return
        }

        DispatchQueue.global(qos: .background).async {
            if let gifImage = UIImage.gif(url: gifURL) {
                GifImageView.cache.setObject(gifImage, forKey: gifURL as NSString)
                DispatchQueue.main.async {
                    uiView.image = gifImage
                }
            }
        }
    }
}
