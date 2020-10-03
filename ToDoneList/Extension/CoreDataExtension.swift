//
//  CoreDataExtension.swift
//  ToDoneList
//
//  Created by m.yamanishi on 2020/10/03.
//  Copyright © 2020 Mayumi Yamanishi. All rights reserved.
//

import CoreData

extension NSPersistentCloudKitContainer {
    
    /// viewContextで保存
    func saveContext() {
        saveContext(context: viewContext)
    }

    /// 指定したcontextで保存
    /// マルチスレッド環境でのバックグラウンドコンテキストを使う場合など
    func saveContext(context: NSManagedObjectContext) {
        
        // 変更がなければ何もしない
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        }
        catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
