//
//  EditorViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 07.03.2025.
//

import SwiftUI
import AVKit
import AVFoundation
import MobileCoreServices
import ImageIO
import UniformTypeIdentifiers

class EditorViewModel: ObservableObject {
    @Published var selectedFileURL: URL? {
        didSet {
            if selectedFileURL != nil {
                DispatchQueue.main.async {
                    self.showVideoPreview = true
                }
            }
        }
    }
    @Published var gifURL: URL?
    @Published var showLoader = false
    @Published var showVideoPreview = false
    @Published var selectedFPS: Int = 10
    @Published var showFPSAlert = false
    @Published var shouldReturnToEditor = false
    
    func deleteGif() {
        if let existingGifURL = gifURL {
            do {
                try FileManager.default.removeItem(at: existingGifURL)
                print("🗑 Видалено попередню GIF: \(existingGifURL)")
            } catch {
                print("⚠️ Помилка видалення попередньої GIF: \(error)")
            }
        }
        resetToEditorView()
    }
    
    func deleteVideoFile() {
        if let videoURL = selectedFileURL {
            do {
                try FileManager.default.removeItem(at: videoURL)
                print("🗑 Видалено відеофайл: \(videoURL)")
            } catch {
                print("⚠️ Помилка видалення відео: \(error)")
            }
        }
        selectedFileURL = nil
    }
    
    func resetToEditorView() {
        gifURL = nil
        selectedFileURL = nil
        showLoader = false
        showVideoPreview = false
        shouldReturnToEditor = true
    }
    
    func convertVideoToGif() {
        guard let videoURL = selectedFileURL else {
            print("❌ Немає вибраного відеофайлу")
            return
        }
        
        showLoader = true
        showVideoPreview = false
        print("ℹ️ Початок конвертації відео у GIF")
        
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("⚠️ Попередження: Відеотрек не знайдено")
            return
        }
        
        let videoSize = videoTrack.naturalSize
        let maxSize: CGFloat = 500
        let aspectRatio = videoSize.width / videoSize.height
        
        let newSize: CGSize
        if videoSize.width > videoSize.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        generator.maximumSize = newSize
        print("ℹ️ Розмір GIF після адаптації: \(newSize.width)x\(newSize.height)")
        
        let frameRate = selectedFPS
        let duration = CMTimeGetSeconds(asset.duration)
        let totalFrames = Int(duration * Double(frameRate))
        
        if totalFrames < 10 {
            showFPSAlert = true
            showLoader = false
            return
        }
        
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
    func saveGif() {
        guard let gifURL = gifURL else { return }

        CoreDataManager.shared.addToCreatedGifs(gifURL: gifURL.absoluteString)
        print("✅ GIF збережено в базу даних: \(gifURL.absoluteString)")
    }
}
