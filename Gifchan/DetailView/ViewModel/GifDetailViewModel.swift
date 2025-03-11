//
//  GifDetailViewModel.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 04.03.2025.
//

import SwiftUI
import PhotosUI

class GifDetailViewModel: ObservableObject {
    @Published var isFavorite: Bool = false
    @Published var isLoading: Bool = false
    @Published var showDownloadAlert: Bool = false
    @Published var showDownloadToast: Bool = false
    @Published var showPermissionAlert = false
    let gifData: Data?
    let gifURL: String?
    
    init(gifData: Data? = nil, gifURL: String? = nil) {
        self.gifData = gifData
        self.gifURL = gifURL
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
            if let gifData = gifData {
                CoreDataManager.shared.addToFavorites(gifData: gifData)
            } else if let gifURL = gifURL {
                CoreDataManager.shared.addToFavorites(gifURL: gifURL)
            }
        } else {
            if let gifData = gifData {
                CoreDataManager.shared.removeFromFavorites(gifData: gifData)
            } else if let gifURL = gifURL {
                CoreDataManager.shared.removeFromFavorites(gifURL: gifURL)
            }
        }
    }
    
    func downloadGif() {
        if let gifData = gifData {
            saveGifToPhotos(gifData: gifData)
        } else if let gifURL = gifURL {
            downloadGif(from: gifURL)
        }
    }
    
    private func downloadGif(from gifURL: String) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.saveGifToPhotos(from: gifURL)
                case .denied, .restricted:
                    self.showPermissionAlert = true
                    self.isLoading = false
                case .notDetermined:
                    print("Очікується дозвіл...")
                @unknown default:
                    print("Невідомий статус дозволу")
                }
            }
        }
    }

    private func saveGifToPhotos(from gifURL: String) {
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: gifURL), let gifData = try? Data(contentsOf: url) else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            self.saveGifToPhotos(gifData: gifData)
        }
    }
    
    private func saveGifToPhotos(gifData: Data) {
        DispatchQueue.global(qos: .background).async {
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: gifData, options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if success {
                        self.showDownloadToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showDownloadToast = false
                        }
                    } else {
                        print("❌ Помилка збереження GIF: \(error?.localizedDescription ?? "Невідома помилка")")
                    }
                }
            }
        }
    }
    
    func checkIfFavorite() {
        if let gifData = gifData {
            isFavorite = CoreDataManager.shared.isGifFavorite(gifData: gifData)
        } else if let gifURL = gifURL {
            isFavorite = CoreDataManager.shared.isGifFavorite(gifURL: gifURL)
        }
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
