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
    @Published var isReference: Bool = false
    @Published var isLoading: Bool = false
    @Published var showDownloadAlert: Bool = false
    @Published var showDownloadToast: Bool = false
    @Published var showPermissionAlert = false

    func toggleFavorite(for gifURL: String) {
        isFavorite.toggle()
        if isFavorite {
            CoreDataManager.shared.addToFavorites(gifURL: gifURL)
        } else {
            CoreDataManager.shared.removeFromFavorites(gifURL: gifURL)
        }
    }

    func toggleReference() {
        isReference.toggle()
    }

    func downloadGif(from gifURL: String) {
            DispatchQueue.main.async {
                self.isLoading = true
            }

            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        self.saveGifToPhotos(gifURL: gifURL)
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

        private func saveGifToPhotos(gifURL: String) {
            DispatchQueue.global(qos: .background).async {
                guard let url = URL(string: gifURL),
                      let gifData = try? Data(contentsOf: url) else {
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }

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

    func checkIfFavorite(for gifURL: String) {
        isFavorite = CoreDataManager.shared.isGifFavorite(gifURL: gifURL)
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
