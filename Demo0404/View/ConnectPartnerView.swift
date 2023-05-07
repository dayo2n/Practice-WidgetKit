//
//  ConnectPartnerView.swift
//  Demo0404
//
//  Created by 제나 on 2023/04/30.
//

import SwiftUI

struct ConnectPartnerView: View {
    
    let user: User
    @State private var partnerCode = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("내코드")
                Text("\(user.code)")
                    .textSelection(.enabled)
            }
            HStack {
                Text("연인과 연결하기")
                TextField("연인코드", text: $partnerCode)
                Button("연결") {
                    AuthViewModel.shared.connect(partnerCode: partnerCode) {
                        
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
