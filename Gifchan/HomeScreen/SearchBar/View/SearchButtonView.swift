//
//  SearchButtonView.swift
//  Gifchan
//
//  Created by Ivan Kisilov on 05.03.2025.
//

import SwiftUI

struct SearchButtonView: View {
    var text: String
    @Binding var searchText: String

    var body: some View {
        Button {
            searchText = text
        } label: {
            Text(text)
                .padding(10)
                .foregroundColor(.stroke)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.stroke, lineWidth: 2)
                )
        }
        .frame(minWidth: 50, maxWidth: .infinity)
    }
}
