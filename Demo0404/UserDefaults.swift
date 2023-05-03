//
//  UserDefaults.swift
//  Demo0404
//
//  Created by 제나 on 2023/05/02.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupID = "group.Demo0404"
        return UserDefaults(suiteName: appGroupID)!
    }
}
