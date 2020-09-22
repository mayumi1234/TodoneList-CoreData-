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
    var dateString: String
    var date: Date
    var documentId: String

    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.detail = dic["detail"] as? String ?? ""
        self.dateString = dic["dateString"] as? String ?? ""
        self.date = (dic["date"] as? Timestamp)?.dateValue() ?? Date()
        self.documentId = dic["documentId"] as? String ?? ""
    }

}
