//
//  GifEditorView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 10.03.2025.
//

import SwiftUI

struct GifEditorView: View {
    @StateObject private var viewModel = GifEditorViewModel()
    let gifData: Data?
    let gifURL: String?
    
    var body: some View {
        VStack {
            if let gifData = gifData {
                ZStack {
                    GifImageView(gifData: gifData, gifURL: nil)
                        .frame(width: 300, height: 300)
                    
                    Text(viewModel.text)
                        .font(.custom(viewModel.selectedFont, size: viewModel.fontSize))
                        .foregroundColor(viewModel.textColor)
                        .offset(viewModel.position)
                        .scaleEffect(viewModel.scale)
                        .rotationEffect(viewModel.rotation)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.position = CGSize(width: value.translation.width, height: value.translation.height)
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    viewModel.scale = value
                                }
                        )
                        .gesture(
                            RotationGesture()
                                .onChanged { value in
                                    viewModel.rotation = value
                                }
                        )
                }
                .frame(width: 300, height: 300)
            } else if let gifURL = gifURL {
                ZStack {
                    GifImageView(gifData: nil, gifURL: gifURL)
                        .frame(width: 300, height: 300)
                    
                    Text(viewModel.text)
                        .font(.custom(viewModel.selectedFont, size: viewModel.fontSize))
                        .foregroundColor(viewModel.textColor)
                        .offset(viewModel.position)
                        .scaleEffect(viewModel.scale)
                        .rotationEffect(viewModel.rotation)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.position = CGSize(width: value.translation.width, height: value.translation.height)
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    viewModel.scale = value
                                }
                        )
                        .gesture(
                            RotationGesture()
                                .onChanged { value in
                                    viewModel.rotation = value
                                }
                        )
                }
                .frame(width: 300, height: 300)
            }
            
            TextField("Введіть текст", text: $viewModel.text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("Шрифт", selection: $viewModel.selectedFont) {
                ForEach(["Arial", "Courier", "Georgia", "Times New Roman", "Verdana"], id: \ .self) { font in
                    Text(font).tag(font)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Slider(value: $viewModel.fontSize, in: 10...50, step: 1)
                .padding()
            
            ColorPicker("Колір тексту", selection: $viewModel.textColor)
                .padding()
            
            Button("Зберегти GIF") {
                viewModel.gifData = gifData
                viewModel.gifUrl = URL(string: gifURL ?? "")
                viewModel.prepareGifForEditing()
            }
            .padding()
            .alert(isPresented: $viewModel.showSaveAlert) {
                Alert(
                    title: Text("GIF Saved"),
                    message: Text("Your GIF has been successfully saved."),
                    dismissButton: .default(Text("OK")) {
                        viewModel.shouldReturnToEditor = true
                    }
                )
            }
        }
        .padding()
        .onChange(of: viewModel.shouldReturnToEditor) { shouldReturn in
            if shouldReturn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.shouldReturnToEditor = false
                }
            }
        }
    }
}
