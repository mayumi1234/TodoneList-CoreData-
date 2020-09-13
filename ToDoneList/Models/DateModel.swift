//
//  Date.swift
//  ToDoneList
//
//  Created by m.yamanishi on 2020/09/12.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import FirebaseFirestore

class DateModel {

    var date: String

    init(dic: [String: Any]) {
        self.date = dic["date"] as? String ?? ""
    }

}
