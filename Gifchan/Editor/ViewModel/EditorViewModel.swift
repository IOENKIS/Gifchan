//
//  EditorViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 07.03.2025.
//

import SwiftUI
import AVFoundation
import MobileCoreServices
import ImageIO
import UniformTypeIdentifiers

class EditorViewModel: ObservableObject {
    @Published var selectedFileURL: URL? {
        didSet {
            print("✅ EditorViewModel: Отримано відео - \(selectedFileURL?.absoluteString ?? "nil")")
            if selectedFileURL != nil {
                convertVideoToGif()
            }
        }
    }
    @Published var gifURL: URL? {
        didSet {
            print("🔄 Оновлено gifURL: \(gifURL?.absoluteString ?? "nil")")
        }
    }
    @Published var showLoader = false

    func convertVideoToGif() {
        guard let videoURL = selectedFileURL else {
            print("❌ Немає вибраного відеофайлу")
            return
        }
        
        // Видаляємо попередню GIF перед створенням нової
        if let existingGifURL = gifURL {
            do {
                try FileManager.default.removeItem(at: existingGifURL)
                print("🗑 Видалено попередню GIF: \(existingGifURL)")
            } catch {
                print("⚠️ Помилка видалення попередньої GIF: \(error)")
            }
        }
        
        // Очищаємо gifURL, щоб змусити UI оновитися
        DispatchQueue.main.async {
            self.gifURL = nil
        }
        
        showLoader = true
        print("ℹ️ Початок конвертації відео у GIF")
        
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            let videoSize = videoTrack.naturalSize
            if videoSize.width > 0 && videoSize.height > 0 {
                let maxSize: CGFloat = 500 // Збільшено максимальний розмір для кращої якості
                let aspectRatio = videoSize.width / videoSize.height
                
                let newSize: CGSize
                if videoSize.width > videoSize.height {
                    newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
                } else {
                    newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
                }
                
                generator.maximumSize = newSize
                print("ℹ️ Розмір GIF після адаптації: \(newSize.width)x\(newSize.height)")
            } else {
                print("⚠️ Попередження: Неможливо отримати розмір відео")
            }
        } else {
            print("⚠️ Попередження: Відеотрек не знайдено")
        }
        
        let frameRate: Int = 20 // Збільшено кількість кадрів за секунду для плавності
        let duration = CMTimeGetSeconds(asset.duration)
        let totalFrames = Int(duration * Double(frameRate))
        let delayBetweenFrames: TimeInterval = 1.0 / Double(frameRate)
        
        print("ℹ️ Загальна тривалість відео: \(duration) секунд")
        print("ℹ️ Очікувана кількість кадрів: \(totalFrames)")
        
        var timeValues: [NSValue] = []
        for frameNumber in 0..<totalFrames {
            let seconds = TimeInterval(frameNumber) * delayBetweenFrames
            let time = CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC))
            timeValues.append(NSValue(time: time))
        }
        
        let gifFilename = "converted.gif"
        let gifURL = FileManager.default.temporaryDirectory.appendingPathComponent(gifFilename)
        
        guard let destination = CGImageDestinationCreateWithURL(gifURL as CFURL, UTType.gif.identifier as CFString, totalFrames, nil) else {
            print("❌ Помилка створення CGImageDestination")
            showLoader = false
            return
        }
        
        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        print("ℹ️ Встановлено параметри GIF")
        
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime: delayBetweenFrames
            ]
        ]
        
        print("ℹ️ Початок створення кадрів GIF")
        var addedFrames = 0
        
        generator.generateCGImagesAsynchronously(forTimes: timeValues) { (requestedTime, image, actualTime, result, error) in
            if let error = error {
                print("❌ Помилка отримання кадру на \(requestedTime.seconds) с: \(error.localizedDescription)")
                return
            }
            
            guard let image = image else {
                print("❌ Отриманий кадр є nil на \(requestedTime.seconds) с")
                return
            }
            
            CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
            addedFrames += 1
            print("✅ Додано кадр у GIF (\(addedFrames)/\(totalFrames))")
            
            if addedFrames == totalFrames {
                print("ℹ️ Всі кадри додані, фіналізація GIF")
                let success = CGImageDestinationFinalize(destination)
                DispatchQueue.main.async {
                    self.showLoader = false
                    if success {
                        self.gifURL = gifURL
                        print("✅ GIF успішно створено: \(gifURL)")
                    } else {
                        print("❌ Помилка при завершенні створення GIF")
                    }
                }
            }
        }
    }
}
