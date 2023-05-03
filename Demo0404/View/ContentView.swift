//
//  ContentView.swift
//  Demo0404
//
//  Created by 제나 on 2023/04/30.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            if viewModel.userSession == nil {
                Text("LOGO")
                    .onAppear {
                        viewModel.signInAnonymously {

                        }
                    }
            } else {
                if let user = viewModel.currentUser {
                    if user.connected {
                        UploadImageView()
                    } else {
                        ConnectPartnerView(user: user)
                    }
                }
            }
        }
        .onAppear {
//            AuthViewModel.shared.signOut()
        }
        .onReceive(timer, perform: { _ in
            if let user = viewModel.currentUser {
                print("here \(viewModel.currentUser)")
                if user.connected {
                    viewModel.getImageUrl()
                }
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
