//
//  VideoPicker.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 07.03.2025.
//

import SwiftUI
import AVFoundation
import MobileCoreServices

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)

            if let mediaURL = info[.mediaURL] as? URL {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("trimmed.mov")
                
                do {
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    try FileManager.default.copyItem(at: mediaURL, to: tempURL)
                    
                    DispatchQueue.main.async {
                        self.parent.selectedURL = tempURL
                    }
                } catch {
                    print("❌ Помилка збереження обрізаного відео: \(error)")
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = [UTType.movie.identifier]
        picker.sourceType = .photoLibrary
        picker.videoQuality = .typeHigh
        picker.allowsEditing = true
        picker.videoMaximumDuration = 10
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
