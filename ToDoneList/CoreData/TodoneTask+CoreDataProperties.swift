//
//  TodoneTask+CoreDataProperties.swift
//  
//
//  Created by m.yamanishi on 2020/10/03.
//
//

import Foundation
import CoreData


extension TodoneTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoneTask> {
        return NSFetchRequest<TodoneTask>(entityName: "TodoneTask")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateString: String?
    @NSManaged public var detail: String?
    @NSManaged public var documentId: String?
    @NSManaged public var name: String?

}
