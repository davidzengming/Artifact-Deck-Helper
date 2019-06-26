//
//  Card.swift
//  ArtifactMe
//
//  Created by David Zeng on 11/21/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CardSetWrapper: Codable {
    let card_set: CardSetReadable
}

struct SetInfoReadable: Codable {
    let set_id: Int
    let pack_item_def: Int
    let name: [String: String]
}

struct CardSetURLReadable: Codable {
    let cdn_root: String
    let url: String
    let expire_time: Date?
}

struct CardSetReadable: Codable {
    let version: Int
    let set_info: SetInfoReadable
    let card_list: [CardReadable]
}

struct ReferenceReadable: Codable {
    let card_id: Int
    let ref_type: String
    let count: Int?
}

struct CardReadable: Codable {
    let card_id: Int
    let base_card_id: Int
    let card_type: String
    let card_name: [String: String]
    let card_text: [String: String]
    var mini_image: [String: String]
    var large_image: [String: String]
    var ingame_image: [String: String]
    let is_green: Bool?
    let is_red: Bool?
    let is_blue: Bool?
    let is_black: Bool?
    let attack: Int?
    let hit_points: Int?
    let references: [ReferenceReadable]
}

struct CardParser {
    private static let dispatchGroup = DispatchGroup()
    private static var cardSetUrl: CardSetURLReadable?
    private static var cardSet: CardSetReadable?
    
    static func parseFromValveAPI() {
        dispatchGroup.enter()
        pingSteamStageOne()
        dispatchGroup.wait()
        
        dispatchGroup.enter()
        verifyExpireTime()
        dispatchGroup.wait()
        
        dispatchGroup.enter()
        pingSteamStageTwo()
        dispatchGroup.wait()
        
        if verifyCardSetVersion() == true {
            return
        }
        clearCoreDataStore()
        saveToCoreData()
    }
    
    private static func verifyCardSetVersion() -> Bool {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CardSet")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [CardSet]
            
            if result.count == 0 || Int(result[0].version) != cardSet?.version {
                return false
            } else {
                return true
            }
        } catch {
            print("Failed to retrieve card set from Core Data.")
        }
        return false
    }
    
    private static func clearCoreDataStore() {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let fetchCardSetUrl = NSFetchRequest<NSFetchRequestResult>(entityName: "CardSetURL")
        let fetchCards = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        let fetchCardSet = NSFetchRequest<NSFetchRequestResult>(entityName: "CardSet")
        let fetchReferences = NSFetchRequest<NSFetchRequestResult>(entityName: "Reference")
        
        let deleteCardSetUrlRequest = NSBatchDeleteRequest(fetchRequest: fetchCardSetUrl)
        let deleteCardsRequest = NSBatchDeleteRequest(fetchRequest: fetchCards)
        let deleteCardSetRequest = NSBatchDeleteRequest(fetchRequest: fetchCardSet)
        let deleteReferences = NSBatchDeleteRequest(fetchRequest: fetchReferences)
        
        do {
            try context.execute(deleteCardSetUrlRequest)
            try context.execute(deleteCardsRequest)
            try context.execute(deleteCardSetRequest)
            try context.execute(deleteReferences)
            try context.save()
            print("Cleared core data store.")
        } catch {
            print("Failed to clear core data store.")
        }
    }
    
    private static func storeImages(_ card: CardReadable, _ cardImagesDispatchGroup: DispatchGroup, _ imageDict: [String: String], _ urlNameSuffix: String) -> String? {
        
        // Image URL does not exist
        if !imageDict.keys.contains("default") {
            return nil
        }
        
        cardImagesDispatchGroup.enter()
        let url = URL(string: imageDict["default"]!)
        let data = try? Data(contentsOf: url!)
        
        if let imageData = data {
            let image = UIImage(data: imageData)
            let imageData = image!.pngData()!
            let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageURL = docDir.appendingPathComponent(String(card.card_id) + urlNameSuffix + ".png")
            try! imageData.write(to: imageURL)
            
            cardImagesDispatchGroup.leave()
            return String(card.card_id) + urlNameSuffix + ".png"
        }
        
        cardImagesDispatchGroup.leave()
        return nil
    }
    
    private static func verifyExpireTime() {
        self.dispatchGroup.leave()
    }
    
    /**
    * Convert readable objects to core data store.
    */
    private static func saveToCoreData() {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext

        // Store care set data
        let cardSetUrlEntity = NSEntityDescription.entity(forEntityName: "CardSetURL", in: context)
        let newCardSetUrl = NSManagedObject(entity: cardSetUrlEntity!, insertInto: context)
        let cardSetEntity = NSEntityDescription.entity(forEntityName: "CardSet", in: context)
        let newCardSet = NSManagedObject(entity: cardSetEntity!, insertInto: context)
        newCardSet.setValue(cardSet!.set_info.name, forKey: "name")
        newCardSet.setValue(cardSet!.set_info.pack_item_def, forKey: "packItemDef")
        newCardSet.setValue(cardSet!.set_info.set_id, forKey: "setId")
        newCardSet.setValue(cardSet!.version, forKey: "version")
        newCardSetUrl.setValue(cardSetUrl?.cdn_root, forKey: "cdnRoot")
        newCardSetUrl.setValue(cardSetUrl?.expire_time, forKey: "expireTime")
        newCardSetUrl.setValue(cardSetUrl?.url, forKey: "url")
        
        let cardImagesDispatchGroup = DispatchGroup()
        // Store each card data
        for var card in cardSet!.card_list {
            let cardEntity = NSEntityDescription.entity(forEntityName: "Card", in: context)
            let newCard = NSManagedObject(entity: cardEntity!, insertInto: context)
            newCard.setValue(card.card_id, forKey: "cardId")
            newCard.setValue(card.base_card_id, forKey: "baseCardId")
            newCard.setValue(card.hit_points, forKey: "hitPoints")
            newCard.setValue(card.card_type, forKey: "cardType")
            newCard.setValue(card.attack, forKey: "attack")
            newCard.setValue(card.is_blue, forKey: "isBlue")
            newCard.setValue(card.is_green, forKey: "isGreen")
            newCard.setValue(card.is_red, forKey: "isRed")
            newCard.setValue(card.is_black, forKey: "isBlack")
            newCard.setValue(card.card_name, forKey: "cardName")
            newCard.setValue(card.card_text, forKey: "cardText")
            
            if card.card_type == "Passive Ability" {
                print(card)
            }
            
            // Retrieves card images asynchronously
            card.ingame_image["local"] = storeImages(card, cardImagesDispatchGroup, card.ingame_image, "ingameImage")
            card.large_image["local"] = storeImages(card, cardImagesDispatchGroup, card.large_image, "largeImage")
            card.mini_image["local"] = storeImages(card, cardImagesDispatchGroup, card.mini_image, "miniImage")
            
            newCard.setValue(card.ingame_image, forKey: "ingameImage")
            newCard.setValue(card.large_image, forKey: "largeImage")
            newCard.setValue(card.mini_image, forKey: "miniImage")
            newCard.setValue(newCardSet, forKey: "cards")
            
            for reference in card.references {
                let referenceEntity = NSEntityDescription.entity(forEntityName: "Reference", in: context)
                let newEntity = NSManagedObject(entity: referenceEntity!, insertInto: context)
                newEntity.setValue(reference.card_id, forKey: "cardId")
                newEntity.setValue(reference.count, forKey: "count")
                newEntity.setValue(reference.ref_type, forKey: "refType")
                newEntity.setValue(newCard, forKey: "references")
            }
        }
        
        cardImagesDispatchGroup.wait()
        
        // Save to Core Data
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    private static func pingSteamStageOne() {
        let redirect_url = URL(string: "https://playartifact.com/cardset/01/")!
        let task = URLSession.shared.dataTask(with: redirect_url) {(data: Data?, response: URLResponse?, error: Error?) in
            if data != nil && error == nil {
                let decoder = JSONDecoder()
                do {
                    self.cardSetUrl = try decoder.decode(CardSetURLReadable
                        .self, from: data!)
                    dispatchGroup.leave()
                } catch _ {
                    print("Fail to decode ------- First Stage")
                }
            } else {
                print("Bad connection detected. Switching to offline mode.")
            }
        }
        task.resume()
    }
    
    private static func pingSteamStageTwo() {
        let card_list_url = URL(string: cardSetUrl!.cdn_root + cardSetUrl!.url)!
        let task = URLSession.shared.dataTask(with: card_list_url) {(data: Data?, response: URLResponse?, error: Error?) in
            if data != nil && error == nil {
                let decoder = JSONDecoder()
                do {
                    let wrapper = try decoder.decode(CardSetWrapper.self, from: data!)
                    cardSet = wrapper.card_set
                    dispatchGroup.leave()
                } catch _ {
                    print("Fail to decode ------- Second Stage ")
                }
            }
        }
        task.resume()
    }
}
