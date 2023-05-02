//
//  UploadImageView.swift
//  Demo0404
//
//  Created by 제나 on 2023/04/30.
//

import SwiftUI
import PhotosUI

struct UploadImageView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @ObservedObject private var viewModel = WidgetViewModel()
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                
                if let selectedImage = selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFill()
                        .clipShape(Rectangle())
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    
                }
            }
            .overlay {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                }
            }
        }
        .onChange(of: selectedItem) { _ in
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        selectedImage = Image(uiImage: image)
                        viewModel.uploadImage(image: image) {
                            return
                        }
                    }
                } else {
                    // TODO: 보관함의 가장 최근 사진을 선택하면 fail to load
                    print("== DEBUG: Failed to load image")
                }
            }
        }
    }
}

struct UploadImageView_Previews: PreviewProvider {
    static var previews: some View {
        UploadImageView()
    }
}
