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
            if let value = snapshot?.value as? [String: Any] {
                
                print("=== SNAPSHOT as [String: Any]: \(value)")
                let user = User(uuid: value["uuid"] as! String, code: value["code"] as! String, partnerCode: value["partnerCode"] as! String)
                self.currentUser = user
                print("=== DEBUG: fetch current user as User.self \(self.currentUser)")
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
                        "partnerCode": ""]
            
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
    
    func connect(_ completion: @escaping() -> Void?) {
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
}
