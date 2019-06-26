//
//  Card+CoreDataProperties.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/17/18.
//  Copyright © 2018 Me. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var attack: Bool
    @NSManaged public var baseCardId: Int32
    @NSManaged public var cardId: Int32
    @NSManaged public var cardName: Dictionary<String, String>?
    @NSManaged public var cardText: Dictionary<String, String>?
    @NSManaged public var cardType: String?
    @NSManaged public var hitPoints: Int32
    @NSManaged public var ingameImage: Dictionary<String, String>?
    @NSManaged public var isBlack: Bool
    @NSManaged public var isBlue: Bool
    @NSManaged public var isGreen: Bool
    @NSManaged public var isRed: Bool
    @NSManaged public var isSignature: Bool
    @NSManaged public var largeImage: Dictionary<String, String>?
    @NSManaged public var miniImage: Dictionary<String, String>?
    @NSManaged public var cards: CardSet?
    @NSManaged public var references: NSSet?

}

// MARK: Generated accessors for references
extension Card {

    @objc(addReferencesObject:)
    @NSManaged public func addToReferences(_ value: Reference)

    @objc(removeReferencesObject:)
    @NSManaged public func removeFromReferences(_ value: Reference)

    @objc(addReferences:)
    @NSManaged public func addToReferences(_ values: NSSet)

    @objc(removeReferences:)
    @NSManaged public func removeFromReferences(_ values: NSSet)

}
