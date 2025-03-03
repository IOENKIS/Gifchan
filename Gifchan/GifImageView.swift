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

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let gifImage = UIImage.gif(url: gifURL) {
                DispatchQueue.main.async {
                    uiView.image = gifImage
                }
            } else {
                print("❌ SwiftGif: Не вдалося завантажити GIF: \(gifURL)")
            }
        }
    }
}

