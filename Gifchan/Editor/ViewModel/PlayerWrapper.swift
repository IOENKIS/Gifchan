//
//  PlayerWrapper.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 09.03.2025.
//

import SwiftUI
import AVKit

class PlayerWrapper: ObservableObject {
    let player: AVPlayer

    init(url: URL?) {
        if let url = url {
            self.player = AVPlayer(url: url)
        } else {
            self.player = AVPlayer()
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
}
