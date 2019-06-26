//
//  CardSet+CoreDataProperties.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/17/18.
//  Copyright © 2018 Me. All rights reserved.
//
//

import Foundation
import CoreData


extension CardSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardSet> {
        return NSFetchRequest<CardSet>(entityName: "CardSet")
    }

    @NSManaged public var name: Dictionary<String, String>?
    @NSManaged public var packItemDef: Int32
    @NSManaged public var setId: Int32
    @NSManaged public var version: Int32
    @NSManaged public var cards: NSSet?

}

// MARK: Generated accessors for cards
extension CardSet {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}
