//
//  Card+CoreDataClass.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/17/18.
//  Copyright © 2018 Me. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Card)
public class Card: NSManagedObject, NSItemProviderWriting {
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [] // something here
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Swift.Void) -> Progress? {
        return nil // something here
    }
}
