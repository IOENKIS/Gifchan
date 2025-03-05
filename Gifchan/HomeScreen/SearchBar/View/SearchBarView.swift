//
//  SearchBarView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 05.03.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onTapAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.stroke)

            TextField("Search gifs...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .foregroundColor(.stroke)
                .background(Color.clear)
                .onTapGesture {
                    onTapAction?()
                }

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.stroke)
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.stroke, lineWidth: 2)
        )
    }
}

