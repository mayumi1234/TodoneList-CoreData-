//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by m.yamanishi on 2020/05/29.
//  Copyright © 2020 mayumi yamanishi. All rights reserved.
//

import FirebaseFirestore

class Task {

    var name: String
    var detail: String
    var date: String
    var documentId: String

    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.detail = dic["detail"] as? String ?? ""
        self.date = dic["date"] as? String ?? ""
        self.documentId = dic["documentId"] as? String ?? ""
    }

}
