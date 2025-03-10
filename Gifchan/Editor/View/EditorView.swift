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
    @State private var showSaveConfirmation = false
    @State private var showGifEditor = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.showLoader {
                    ProgressView("GIF processing...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    Text("This may take a few seconds.")
                         .foregroundColor(.gray)
                } else if let gifURL = viewModel.gifURL {
                    GifImageView(gifData: nil, gifURL: gifURL.absoluteString)
                        .frame(width: 400, height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .padding()
                    
                    HStack {
                        Button(action: {
                            viewModel.saveGif()
                            showSaveConfirmation = true
                         }) {
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color.stroke, lineWidth: 2)
                                 .frame(height: 50)
                                 .overlay(
                                    Text("Save")
                                        .foregroundColor(.stroke)
                                        .padding()
                                 )
                         }
                         .padding()
                        
                        Button(action: {
                            showGifEditor = true
                         }) {
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color.stroke, lineWidth: 2)
                                 .frame(height: 50)
                                 .overlay(
                                    Text("Edit")
                                         .foregroundColor(.stroke)
                                         .padding()
                                 )
                         }
                         .padding()
                        
                        Button(action: {
                            viewModel.deleteGif()
                         }) {
                             RoundedRectangle(cornerRadius: 15)
                                 .stroke(Color.stroke, lineWidth: 2)
                                 .frame(height: 50)
                                 .overlay(
                                    Text("Delete")
                                         .foregroundColor(.stroke)
                                         .padding()
                                 )
                         }
                         .padding()
                    }
                    NavigationLink(destination: GifEditorView(gifData: try? Data(contentsOf: gifURL), gifURL: nil), isActive: $showGifEditor) { EmptyView() }
                } else {
                    Text("Choose a GIF or video")
                         .foregroundColor(.gray)
                         .padding()
                    
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
                     .sheet(isPresented: $showVideoPicker) {
                         VideoPicker(selectedURL: $viewModel.selectedFileURL)
                     }
                }
                NavigationLink(destination: VideoPreviewView(viewModel: viewModel), isActive: $viewModel.showVideoPreview) { EmptyView() }
            }
            .navigationTitle("Create GIF")
            .alert(isPresented: $showSaveConfirmation) {
                Alert(
                    title: Text("GIF Saved"),
                    message: Text("Your GIF has been successfully saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
