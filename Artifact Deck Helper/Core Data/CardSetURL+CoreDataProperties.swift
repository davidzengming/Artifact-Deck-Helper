//
//  CardSetURL+CoreDataProperties.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/17/18.
//  Copyright © 2018 Me. All rights reserved.
//
//

import Foundation
import CoreData


extension CardSetURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardSetURL> {
        return NSFetchRequest<CardSetURL>(entityName: "CardSetURL")
    }

    @NSManaged public var cdnRoot: String?
    @NSManaged public var expireTime: NSDate?
    @NSManaged public var url: String?

}
