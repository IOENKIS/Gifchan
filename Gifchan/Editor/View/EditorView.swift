//
//  EditorView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 07.03.2025.
//

import SwiftUI

struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
    @State private var showVideoPicker = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.showLoader {
                    VStack {
                        ProgressView("Processing GIF...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                        Text("This may take a few seconds.")
                            .foregroundColor(.gray)
                    }
                } else if let gifURL = viewModel.gifURL {
                    GifImageView(gifURL: gifURL.absoluteString)
                        .frame(width: 500, height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .padding()
                } else {
                    Text("Select the video to convert to GIF")
                        .foregroundColor(.gray)
                        .padding()
                }

                Button(action: {
                    showVideoPicker = true
                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.stroke, lineWidth: 2)
                        .frame(height: 50)
                        .overlay(
                            Label("Download video", systemImage: "photo.fill")
                                .foregroundColor(.stroke)
                                .padding()
                        )
                }
                .padding()
            }
            .navigationTitle("Create GIF")
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(selectedURL: $viewModel.selectedFileURL)
            }
        }
    }
}
