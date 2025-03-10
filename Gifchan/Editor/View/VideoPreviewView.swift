//
//  VideoPreviewView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 09.03.2025.
//

import SwiftUI
import AVFoundation
import AVKit

struct VideoPreviewView: View {
    @ObservedObject var viewModel: EditorViewModel
    @StateObject private var playerWrapper: PlayerWrapper

    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        _playerWrapper = StateObject(wrappedValue: PlayerWrapper(url: viewModel.selectedFileURL))
    }

    var body: some View {
        VStack {
            VideoPlayer(player: playerWrapper.player)
                .frame(height: 400)
                .cornerRadius(10)
                .padding()
                .onAppear {
                    playerWrapper.play()
                }
                .onDisappear {
                    playerWrapper.pause()
                }
            
            Picker("FPS", selection: $viewModel.selectedFPS) {
                Text("10 FPS").tag(10)
                Text("20 FPS").tag(20)
                Text("30 FPS").tag(30)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: viewModel.selectedFPS) { _ in
                print("🔄 FPS змінено: \(viewModel.selectedFPS)")
            }
            
            Button("Конвертувати у GIF") {
                viewModel.convertVideoToGif()
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showFPSAlert) {
            Alert(
                title: Text("Недостатньо кадрів"),
                message: Text("Ваше відео не підтримує вибраний FPS. Спробуйте знизити до 10 або 20 FPS."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
