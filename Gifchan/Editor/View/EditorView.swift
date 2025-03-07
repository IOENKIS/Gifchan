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
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .padding()
                } else {
                    Text("Choose a GIF or video")
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
                            Label("Upload a GIF or video", systemImage: "photo.fill")
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
