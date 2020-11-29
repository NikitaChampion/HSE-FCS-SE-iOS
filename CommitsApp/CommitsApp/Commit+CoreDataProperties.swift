//
//  Commit+CoreDataProperties.swift
//  CommitsApp
//
//  Created by Никита Игумнов on 29.11.2020.
//
//

import Foundation
import CoreData


extension Commit {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var url: String
    @NSManaged public var sha: String
    @NSManaged public var message: String
    @NSManaged public var date: Date
    @NSManaged public var author: Author
}

extension Commit : Identifiable {

}
