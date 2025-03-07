//
//  EditorViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 07.03.2025.
//

@preconcurrency import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

@MainActor
class EditorViewModel: ObservableObject {
    @Published var selectedFileURL: URL? {
        didSet {
            handleSelectedFile()
        }
    }
    @Published var gifURL: URL?
    @Published var isProcessing = false
    @Published var showLoader = false

    private func handleSelectedFile() {
        guard let fileURL = selectedFileURL else { return }

        DispatchQueue.main.async {
            self.gifURL = nil
            self.isProcessing = true
            self.showLoader = true
        }

        Task {
            await convertVideoToGIF(videoURL: fileURL)
        }
    }

    func convertVideoToGIF(videoURL: URL) async {
        let tempGifURL = FileManager.default.temporaryDirectory.appendingPathComponent("converted.gif")
        let asset = AVURLAsset(url: videoURL)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("❌ Не вдалося отримати трек відео")
            return
        }

        let originalFPS = track.nominalFrameRate
        let videoSize = track.naturalSize.applying(track.preferredTransform) // ✅ Отримуємо оригінальний розмір відео
        var duration = asset.duration.seconds
        let optimizedFPS: Float = min(originalFPS, 20) // 🔥 Обмежуємо FPS до 20

        if duration > 10 {
            print("⚠️ Відео довше 10 секунд, обрізаємо...")
            duration = 10
        }

        let stepTime = 1.0 / Double(optimizedFPS)
        let totalFrames = Int(duration * Double(optimizedFPS))
        var timeValues: [NSValue] = []
        var currentTime: Double = 0.0

        while currentTime < duration {
            let time = CMTime(seconds: currentTime, preferredTimescale: 600)
            timeValues.append(NSValue(time: time))
            currentTime += stepTime
        }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.maximumSize = videoSize // ✅ Масштабуємо GIF до розміру відео

        guard let destination = CGImageDestinationCreateWithURL(tempGifURL as CFURL, UTType.gif.identifier as CFString, totalFrames, nil) else {
            print("❌ Не вдалося створити GIF файл")
            return
        }

        let gifProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0 // 🔄 Безкінечна анімація
            ]
        ] as CFDictionary
        CGImageDestinationSetProperties(destination, gifProperties)

        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: max(0.03, 1.0 / 20.0) // 🛠 Мінімальна затримка між кадрами
            ]
        ] as CFDictionary

        let dispatchGroup = DispatchGroup()
        var framesProcessed = 0

        print("📸 Починаємо обробку \(totalFrames) кадрів...")

        for timeValue in timeValues {
            dispatchGroup.enter()

            generator.generateCGImagesAsynchronously(forTimes: [timeValue]) { (requestedTime, resultingImage, actualTime, result, error) in
                defer { dispatchGroup.leave() }

                if let error = error {
                    print("⚠️ Помилка генерації кадру для \(requestedTime.seconds) сек: \(error.localizedDescription)")
                    return
                }

                guard let resultingImage = resultingImage else {
                    print("⚠️ Не отримано зображення для часу \(requestedTime.seconds) сек")
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    CGImageDestinationAddImage(destination, resultingImage, frameProperties)
                    DispatchQueue.main.async {
                        framesProcessed += 1
                        print("📸 Додано кадр \(framesProcessed)/\(totalFrames)")
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if framesProcessed == 0 {
                print("❌ У GIF не було додано жодного кадру!")
                return
            }

            print("🎥 Готово! GIF створено. Кадрів: \(framesProcessed)/\(totalFrames)")
            CGImageDestinationFinalize(destination)

            DispatchQueue.main.async {
                self.gifURL = tempGifURL
                self.showLoader = false
                self.isProcessing = false
            }
        }
    }
}
