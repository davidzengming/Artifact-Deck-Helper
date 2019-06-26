//
//  Reference+CoreDataProperties.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/17/18.
//  Copyright © 2018 Me. All rights reserved.
//
//

import Foundation
import CoreData


extension Reference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reference> {
        return NSFetchRequest<Reference>(entityName: "Reference")
    }

    @NSManaged public var cardId: Int32
    @NSManaged public var count: Int32
    @NSManaged public var refType: String?
    @NSManaged public var references: Card?

}
