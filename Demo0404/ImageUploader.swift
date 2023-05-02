//
//  ImageUploader.swift
//  Demo0404
//
//  Created by 제나 on 2023/05/02.
//

import UIKit
import Foundation
import FirebaseStorage

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let ref = Storage.storage().reference(withPath: "/images/\(uid)")
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("=== DEBUG: 이미지 업로드 실패 \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url , _ in
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl)
            }
        }
    }
}
