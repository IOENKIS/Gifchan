//
//  Swift+Gif.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import UIKit
import ImageIO

extension UIImage {
    
    public class func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("❌ SwiftGif: Невірний формат GIF (немає джерела)")
            return nil
        }

        let count = CGImageSourceGetCount(source)
        guard count > 1 else {
            print("⚠️ SwiftGif: Це статичне зображення, а не GIF")
            return UIImage(data: data) // ✅ Повертаємо звичайне зображення, якщо це не GIF
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        guard let bundleURL = URL(string: url) else {
            print("❌ SwiftGif: Невірний URL: \(url)")
            return nil
        }

        do {
            let imageData = try Data(contentsOf: bundleURL)
            return gif(data: imageData)
        } catch {
            print("❌ SwiftGif: Не вдалося завантажити GIF за URL: \(url)")
            return nil
        }
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var delays = [Int]()

        for index in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(UIImage(cgImage: image))
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index, source: source)
            delays.append(Int(delaySeconds * 1000.0))
        }

        let duration = delays.reduce(0, +)
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        for index in 0..<count {
            let frame = images[index]
            let frameCount = delays[index] / gcd

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        return UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }

        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)

        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1
        }

        return delay
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs

        if rhs == nil || lhs == nil {
            return lhs ?? rhs ?? 0
        }

        if lhs! < rhs! {
            let temp = lhs
            lhs = rhs
            rhs = temp
        }

        var rest: Int
        while true {
            rest = lhs! % rhs!
            if rest == 0 {
                return rhs!
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
