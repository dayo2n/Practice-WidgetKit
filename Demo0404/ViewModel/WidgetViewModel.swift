//
//  WidgetViewModel.swift
//  Demo0404
//
//  Created by 제나 on 2023/05/02.
//

import Firebase

class WidgetViewModel: ObservableObject {
    @Published var imageUrl: String?
    
    init() {
        
    }
    
    func uploadImage(image: UIImage, _ completion: @escaping() -> Void?) {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        ImageUploader.uploadImage(image: image) { imageUrl in
            Database.database().reference().ref.child("users/\(uid)/").updateChildValues(["imageUrl": imageUrl]) { error, ref in
                if let error = error {
                    print("== DEBUG: image 업로드 및 DB에 image url 업데이트 실패")
                } else {
                    print("== DEBUG: image 업로드 및 DB에 image url 업데이트 성공")
                }
            }
        }
    }
}
