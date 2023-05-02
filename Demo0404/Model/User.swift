//
//  User.swift
//  Demo0404
//
//  Created by 제나 on 2023/04/30.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    var uuid: String
    var code: String
    var partnerCode: String
}
