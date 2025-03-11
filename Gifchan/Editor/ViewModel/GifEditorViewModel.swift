//
//  GifEditorViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 10.03.2025.
//

import SwiftUI
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers

class GifEditorViewModel: ObservableObject {
    @Published var gifData: Data?
    @Published var gifUrl: URL?
    @Published var text = "Your text"
    @Published var textColor = Color.white
    @Published var fontSize: CGFloat = 24
    @Published var position = CGSize(width: 0, height: 0)
    @Published var scale: CGFloat = 1.0
    @Published var rotation: Angle = .zero
    @Published var selectedFont = "Arial"
    @Published var showSaveAlert = false
    @Published var shouldReturnToEditor = false
    @Published var gifSize: CGSize = .zero
    private var temporaryGifURL: URL?
    
    func prepareGifForEditing() {
        print("🔍 Перевіряємо вхідні дані...")
        print("🎞 gifData: \(gifData != nil ? "✅ Є" : "❌ Немає")")
        print("🌐 gifUrl: \(gifUrl?.absoluteString ?? "❌ Немає")")

        if let gifData = gifData {
            print("✅ GIF уже завантажений, починаємо обробку")
            saveGifWithText()
            return
        }

        guard let gifUrl = gifUrl else {
            print("❌ Немає ні `gifData`, ні `gifUrl`, не можемо продовжити")
            return
        }

        print("⏳ Завантаження GIF з URL: \(gifUrl) у тимчасову директорію...")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let downloadedGifData = try Data(contentsOf: gifUrl)
                
                let tempGifURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_gif.gif")
                try downloadedGifData.write(to: tempGifURL)

                DispatchQueue.main.async {
                    self.temporaryGifURL = tempGifURL
                    self.gifData = downloadedGifData
                    print("✅ GIF завантажено у тимчасову директорію: \(tempGifURL)")

                    self.saveGifWithText()
                }
            } catch {
                print("❌ Помилка завантаження GIF: \(error)")
            }
        }
    }

    func saveGifWithText() {
        guard let gifData = gifData else {
            print("❌ Немає даних GIF для обробки")
            return
        }
        
        guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("❌ Помилка завантаження вихідного GIF")
            return
        }
        
        let frameCount = CGImageSourceGetCount(source)
        let gifDestinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("edited.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(gifDestinationURL as CFURL, UTType.gif.identifier as CFString, frameCount, nil) else {
            print("❌ Помилка створення CGImageDestination")
            return
        }
        
        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        for i in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
            if let newFrame = renderTextOnImage(cgImage) {
                CGImageDestinationAddImage(destination, newFrame, frameProperties as CFDictionary?)
            }
        }
        
        if CGImageDestinationFinalize(destination) {
            print("✅ GIF успішно створено: \(gifDestinationURL)")
            
            do {
                let savedGifData = try Data(contentsOf: gifDestinationURL)
                CoreDataManager.shared.addToCreatedGifs(gifData: savedGifData)
                print("✅ GIF збережено в базу даних")

                // Видаляємо тимчасовий файл, якщо він є
                if let tempURL = self.temporaryGifURL {
                    try FileManager.default.removeItem(at: tempURL)
                    print("🗑 Видалено тимчасовий GIF-файл: \(tempURL)")
                }

                DispatchQueue.main.async {
                    self.showSaveAlert = true
                    self.shouldReturnToEditor = true
                }
            } catch {
                print("❌ Помилка збереження GIF у базу даних: \(error)")
            }
        } else {
            print("❌ Помилка при завершенні створення GIF")
        }
    }
    
    func renderTextOnImage(_ cgImage: CGImage) -> CGImage? {
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        print("🎞 Розмір GIF: \(imageWidth)x\(imageHeight)")
        
        guard let context = CGContext(
            data: nil,
            width: Int(imageWidth),
            height: Int(imageHeight),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            print("❌ Неможливо створити CGContext")
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))

        print("📍 Позиція тексту (до трансформацій): \(position.width), \(position.height)")

        context.translateBy(x: 0, y: imageHeight)
        context.scaleBy(x: 1.0, y: -1.0)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: selectedFont, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor(textColor)
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedText.boundingRect(
            with: CGSize(width: imageWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        ).size

        // Центруємо текст відповідно до заданої позиції
        let adjustedX = (imageWidth / 2) + position.width - textSize.width / 2
        let adjustedY = (imageHeight / 2) + position.height - textSize.height / 2

        let textRect = CGRect(
            x: adjustedX,
            y: adjustedY,
            width: textSize.width,
            height: textSize.height
        )
        
        print("📝 Розмір тексту: \(textSize.width)x\(textSize.height)")
        print("📍 Остаточна позиція тексту: \(textRect.origin.x), \(textRect.origin.y)")

        UIGraphicsPushContext(context)
        attributedText.draw(in: textRect)
        UIGraphicsPopContext()

        return context.makeImage()
    }

    
    func textBoundingRect() -> CGRect {
        let textWidth = fontSize * CGFloat(text.count) * 0.6
        let textHeight = fontSize
        return CGRect(
            x: 0,
            y: 0,
            width: textWidth,
            height: textHeight
        )
    }
}
