//
//  GifModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import Foundation

struct GifResponse: Codable {
    let data: [GifData]
}

struct GifData: Codable, Identifiable {
    let id: String
    let images: GifImages
}

struct GifImages: Codable {
    let fixedHeight: GifImageDetails

    enum CodingKeys: String, CodingKey {
        case fixedHeight = "fixed_height"
    }
}

struct GifImageDetails: Codable {
    let url: String
}
