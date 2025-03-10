//
//  GifDetailView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 03.03.2025.
//

import SwiftUI

struct GifDetailView: View {
    let gifData: Data?
    let gifURL: String?
    @StateObject private var viewModel: GifDetailViewModel
    
    init(gifData: Data? = nil, gifURL: String? = nil) {
        self.gifData = gifData
        self.gifURL = gifURL
        _viewModel = StateObject(wrappedValue: GifDetailViewModel(gifData: gifData, gifURL: gifURL))
    }

    var body: some View {
        ZStack{
            VStack {
                GifImageView(gifData: gifData, gifURL: gifURL)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                    .padding()
                
                VStack(spacing: 20) {
                    buttonForDetail(
                        isActive: viewModel.isFavorite,
                        action: { viewModel.toggleFavorite() },
                        title: "Add to Favorite",
                        activeIcon: "heart.fill",
                        inactiveIcon: "heart"
                    )
                    
                    buttonForDetail(
                        isActive: viewModel.isReference,
                        action: { viewModel.toggleReference() },
                        title: "Take as Reference",
                        activeIcon: "pencil.circle.fill",
                        inactiveIcon: "pencil.circle"
                    )
                    
                    buttonForDetail(
                        isActive: false,
                        action: { viewModel.downloadGif() },
                        title: "Add to gallery",
                        activeIcon: "arrow.down.circle.fill",
                        inactiveIcon: "arrow.down.circle"
                    )
                }
                .padding(.horizontal)
            }
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .background))
                        .scaleEffect(2)
                    Text("Downloading GIF...")
                        .foregroundColor(.background)
                        .font(.headline)
                        .padding(.top, 10)
                }
                .frame(width: 200, height: 150)
                .background(Color.stroke.opacity(0.8))
                .cornerRadius(15)
            }
            
            if viewModel.showDownloadToast {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.background)
                            .font(.title2)
                        Text("GIF successfully saved!")
                            .foregroundColor(.background)
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.stroke.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showDownloadToast)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("GIF Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.checkIfFavorite()
        }
        .alert(isPresented: $viewModel.showDownloadAlert) {
            Alert(
                title: Text("Download Complete"),
                message: Text("GIF has been saved to your Photos"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $viewModel.showPermissionAlert) {
            Alert(
                title: Text("Access denied"),
                message: Text("To save GIFs, allow access to Photos in Settings"),
                primaryButton: .default(Text("Settings"), action: {
                    viewModel.openSettings()
                }),
                secondaryButton: .cancel(Text("Close"))
            )
        }
    }

    func buttonForDetail(
        isActive: Bool,
        action: @escaping () -> Void,
        title: String,
        activeIcon: String,
        inactiveIcon: String?
    ) -> some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 20)
                .fill(isActive ? Color.stroke : Color.clear)
                .frame(height: 50)
                .overlay(
                    Label(title, systemImage: (isActive ? activeIcon : inactiveIcon) ?? activeIcon)
                        .foregroundColor(isActive ? .background : .stroke)
                        .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.stroke, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: isActive)
        }
    }
}
