//
//  ContentView.swift
//  Demo0404
//
//  Created by 제나 on 2023/04/30.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if viewModel.userSession == nil {
                ConnectPartnerView()
                    .onAppear {
                        viewModel.signInAnonymously {

                        }
                    }
            } else {
                if let user = viewModel.currentUser {
                    if user.connected {
                        UploadImageView()
                    } else {
                        ConnectPartnerView()
                    }
                }
            }
        }
        .onAppear {
            print("here \(viewModel.currentUser)")
//            AuthViewModel.shared.signOut()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
