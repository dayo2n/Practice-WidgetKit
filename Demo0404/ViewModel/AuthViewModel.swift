//
//  AuthViewModel.swift
//  Demo0404
//
//  Created by 제나 on 2023/04/30.
//

import Firebase

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    static let shared = AuthViewModel()
    
    init() {
        userSession = Auth.auth().currentUser // makes a API call to the firebase server
        // If there is no login information, userSession would be 'nil'
        fetchUser()
    }
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        print("=== DEBUG: fetch userSession uid \(uid)")
        
        Database.database().reference().ref.child("users/\(uid)").getData { error, snapshot in
            if let err = error {
                print("== DEBUG: \(err.localizedDescription)")
            }
            
            print("=== SNAPSHOT: \(snapshot?.value)")
            // TODO: snapshot data JSONDecoder로 디코딩
            if let value = snapshot?.value as? [String: Any] {
                let user = User(uuid: value["uuid"] as! String, code: value["code"] as! String, partnerCode: value["partnerCode"] as! String, connected: value["connected"] as! Bool)
                self.currentUser = user
            }
        }
    }
    
    func signInAnonymously(_ completion: @escaping() -> Void?) {
        let uuid = getDeviceUUID()
        
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("== DEBUG register(): error \(error.localizedDescription)")
            }
            
            guard let user = result?.user else { return }
            print("== DEBUG register(): \(user) \(user.uid)")
            UserDefaults.standard.set(user.uid, forKey: "code")
            
            let data = ["uuid": uuid,
                        "code": user.uid,
                        "partnerCode": "",
                        "connected": false]
            
            Database.database().reference().ref.child("users").child(user.uid).setValue(data) { error, ref  in
                if let error = error {
                    print("DEBUG: register() database error \(error.localizedDescription)")
                }
                completion()
                
                self.fetchUser()
            }
        }
    }
    
    private func getDeviceUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    func connect(partnerCode: String, _ completion: @escaping() -> Void?) {
        guard let uid = userSession?.uid else { return }
        
        // TODO: 1. partnerCode DB 업데이트하고
        Database.database().reference().ref.child("users/\(uid)/").updateChildValues(["partnerCode": partnerCode]) { error, ref in
            if let error = error {
                print("== DEBUG: 파트너코드 등록 오류 \(error)")
            } else {
                print("== DEBUG: 파트너코드 등록 성공!")
                self.currentUser?.partnerCode = partnerCode
            }
            
            // TODO: 2. 파트너가 나를 등록하여 대기중인지 확인
            Database.database().reference().ref.child("users/\(partnerCode)").getData { error, snapshot in
                if let err = error {
                    print("== DEBUG: 파트너코드 오타, 오류 확인필 \(err.localizedDescription)")
                }
                
                print("=== SNAPSHOT: \(snapshot?.value)")
                if let partnerValue = snapshot?.value as? [String: Any] {
                    if partnerValue["partnerCode"] as! String == uid {
                        self.currentUser?.connected = true
                        Database.database().reference().ref.child("users/\(uid)/").updateChildValues(["connected": true])
                        Database.database().reference().ref.child("users/\(partnerCode)/").updateChildValues(["connected": true])
                    } else {
                        print("== DEBUG: connect 실패. 파트너코드가 서로 매치되지 않거나 상대가 아직 등록하지 않아 대기중인 상태")
                    }
                }
            }
        }
    }
    
    /**
     0404에는 로그아웃에 대한 기능 명세가 없습니다. 테스트용으로 구현된 메소드이니 사용하지 마세요.
     */
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("== DEBUG: Error signing out \(error.localizedDescription)")
        }
    }
    
    // MARK: - 위치가 잘못된듯한 메소드 ....
    
    // TODO: 코드 정리 좀...
    func getImageUrl(_ completion: @escaping(String) -> Void?) {
        // TODO: uploadImage에서 파트너 이미지 url까지 업로드하고 여기서는 파트너의 이미지를 조회하는게 나을듯
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        let ref = Database.database().reference().ref
        ref.child("users/\(uid)/").getData { error, snapshot in
            if let value = snapshot?.value as? [String: Any] {
                let partnerCode = value["partnerCode"] as! String
                ref.child("users/\(partnerCode)/").getData { error, snapshot in
                    if let error = error {
                        print("== DEBUG: 이미지 url 못불러옴")
                    } else {
                        if let partnerValue = snapshot?.value as? [String: Any],
                           let partnerImageUrl = partnerValue["imageUrl"] as? String{
                            print("== DEBUG: 불러온 image url \n\(partnerValue["imageUrl"] as! String)")
                            
                            guard let url = URL(string: partnerImageUrl) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url) { data, response, error in
                                guard let data = data, error == nil else {
                                    return
                                }
                                self.setImageInUserDefaults(UIImage: UIImage(data: data) ?? UIImage(), "widgetImage")
                            }.resume()
                        }
                    }
                }
            }
        }
    }
    
    /// UIImage convert to NSData
    func setImageInUserDefaults(UIImage value: UIImage, _ key: String) {
            let imageData = value.jpegData(compressionQuality: 0.5)
            UserDefaults.shared.set(imageData, forKey: key)
    }
}
