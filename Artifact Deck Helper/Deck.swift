//
//  Deck.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/18/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

class Deck {
    private var mainDeckArray = [Card]()
    private var mainDeckCountTracker = [Int: Int]()
    private var itemDeckArray = [Card]()
    private var itemDeckCountTracker = [Int: Int]()
    private var cardIndexTableTracker = [Card: Int]()
    
    private var heroDeck = [Card]()
    private var colorCount = ["Blue": 0, "Black": 0, "Red": 0, "Green": 0]
    
    private let minimumMainDeckSizeCount = 25
    private let minimumItemDeckSizeCount = 9
    private let minimumHeroesCount = 5
    private let maxCopiesOfNonHeroCard = 3
    
    // Main deck
    private var mainDeckTypeCount = ["Spell": 0, "Creep": 0, "Improvement": 0]
    
    // Item deck
    private var itemDeckTypeCount = ["Weapon": 0, "Armor": 0, "Health": 0, "Utility": 0]
    
    func getDeckArray() -> [Card] {
        return mainDeckArray + itemDeckArray
    }
    
    func getHeroesCount() -> Int {
        return minimumHeroesCount
    }
    
    func getHeroesDeck() -> [Card] {
        return heroDeck
    }
    
    func getColorCount() -> [String: Int] {
        return colorCount
    }
    
    func getItemDeckCount() -> Int {
        return itemDeckArray.count
    }
    
    func getDeckTypeCount() -> [String: Int] {
        return mainDeckTypeCount
    }
    
    func findRowIndexWith(_ targetCard: Card) -> Int {
        let deck = mainDeckArray + itemDeckArray
        for (index, card) in deck.enumerated() {
            if targetCard == card {
                return index
            }
        }
        
        // shouldnt happen error
        return -1
    }
    
    func addToDeck(_ card: Card, with cardHashMap: [Int: Card]) {
        switch(card.cardType) {
        case "Hero":
            if heroDeck.contains(card) || heroDeck.count == 5 {
                return
            }
            
            for reference in card.references?.allObjects as! [Reference] {
                let referenceCard = cardHashMap[Int(reference.cardId)]!
                if referenceCard.cardType != "Passive Ability" && referenceCard.cardType != "Ability" {
                    referenceCard.isSignature = true
                    mainDeckCountTracker[Int(reference.cardId)] = 3
                    
                    if referenceCard.cardType == "Spell" {
                        mainDeckTypeCount["Spell"]! += 3
                    } else if referenceCard.cardType == "Creep" {
                        mainDeckTypeCount["Creep"]! += 3
                    } else {
                        mainDeckTypeCount["Improvement"]! += 3
                    }
                    
                    mainDeckArray.append(referenceCard)
                }
            }
            
            if card.isRed {
                colorCount["Red"]! += 3
            } else if card.isBlue {
                colorCount["Blue"]! += 3
            } else if card.isBlack {
                colorCount["Black"]! += 3
            } else if card.isGreen {
                colorCount["Green"]! += 3
            }
            
            heroDeck.append(card)
        case "Spell", "Creep", "Improvement":
            let cardIdInt = Int(card.cardId)
            
            if (mainDeckCountTracker[cardIdInt] != nil) && (mainDeckCountTracker[cardIdInt]! < maxCopiesOfNonHeroCard) {
                mainDeckCountTracker[cardIdInt]! += 1
                
            } else if (mainDeckCountTracker[cardIdInt] != nil) && (mainDeckCountTracker[cardIdInt]! == maxCopiesOfNonHeroCard) {
                // ignore case
                return
            } else {
                mainDeckCountTracker[cardIdInt] = 1
                mainDeckArray.append(card)
            }
            
            if card.cardType == "Spell" {
                mainDeckTypeCount["Spell"]! += 1
            } else if card.cardType == "Creep" {
                mainDeckTypeCount["Creep"]! += 1
            } else {
                mainDeckTypeCount["Improvement"]! += 1
            }
            
            if card.isRed {
                colorCount["Red"]! += 1
            } else if card.isBlue {
                colorCount["Blue"]! += 1
            } else if card.isBlack {
                colorCount["Black"]! += 1
            } else if card.isGreen {
                colorCount["Green"]! += 1
            }
            
        case "Item":
            let cardIdInt = Int(card.cardId)
            if (itemDeckCountTracker[cardIdInt] != nil) && (itemDeckCountTracker[cardIdInt]! < maxCopiesOfNonHeroCard) {
                itemDeckCountTracker[cardIdInt]! += 1
            } else if (itemDeckCountTracker[cardIdInt] != nil) && (itemDeckCountTracker[cardIdInt]! == maxCopiesOfNonHeroCard) {
                return
                // ignore case
            } else {
                itemDeckCountTracker[cardIdInt] = 1
                itemDeckArray.append(card)
            }
            
        default:
            print("Uncaught card type found: " + card.cardType!)
        }
        
    }
    
    func removeCardFromDeck(at index: Int, with cardHashMap: [Int: Card]) {
        // is an item
        if index >= mainDeckArray.count {
            let cardId = Int(itemDeckArray[index - mainDeckArray.count].cardId)
            itemDeckCountTracker[cardId]! -= 1
            if itemDeckCountTracker[cardId]! == 0 {
                itemDeckArray.remove(at: index - mainDeckArray.count)
                itemDeckCountTracker.removeValue(forKey: cardId)
            }
        // is not an item
        } else {
            let cardId = Int(mainDeckArray[index].cardId)
            let card = cardHashMap[cardId]!
            
            if card.isSignature == true {
                return
            }
            
            if card.cardType == "Spell" {
                mainDeckTypeCount["Spell"]! -= 1
            } else if card.cardType == "Creep" {
                mainDeckTypeCount["Creep"]! -= 1
            } else {
                mainDeckTypeCount["Improvement"]! -= 1
            }
            
            if card.isRed {
                colorCount["Red"]! -= 1
            } else if card.isBlue {
                colorCount["Blue"]! -= 1
            } else if card.isBlack {
                colorCount["Black"]! -= 1
            } else if card.isGreen {
                colorCount["Green"]! -= 1
            }
            
            mainDeckCountTracker[cardId]! -= 1
            if mainDeckCountTracker[cardId]! == 0 {
                mainDeckArray.remove(at: index)
                mainDeckCountTracker.removeValue(forKey: cardId)
            }
        }
    }
    
    func removeHeroFromDeck(at index: Int, with cardHashMap: [Int: Card]) {
        if index < heroDeck.count {
            let hero = heroDeck[index]
            
            if hero.isRed {
                colorCount["Red"]! -= 3
            } else if hero.isBlue {
                colorCount["Blue"]! -= 3
            } else if hero.isBlack {
                colorCount["Black"]! -= 3
            } else if hero.isGreen {
                colorCount["Green"]! -= 3
            }
            
            for reference in hero.references?.allObjects as! [Reference] {
                let referenceCard = cardHashMap[Int(reference.cardId)]!
                if referenceCard.cardType != "Passive Ability" && referenceCard.cardType != "Ability" {
                    for (i, card) in mainDeckArray.enumerated() {
                        if referenceCard == card {
                            mainDeckArray.remove(at: i)
                            if referenceCard.cardType == "Spell" {
                                mainDeckTypeCount["Spell"]! -= 3
                            } else if referenceCard.cardType == "Creep" {
                                mainDeckTypeCount["Creep"]! -= 3
                            } else {
                                mainDeckTypeCount["Improvement"]! -= 3
                            }
                            break
                        }
                    }
                }
            }
            
            heroDeck.remove(at: index)
        }
        
        
    }
    
    func getCardCount() -> Int {
        return mainDeckArray.count + itemDeckArray.count
    }
    
    func getCount(forCard card: Card) -> Int {
        if card.cardType! == "Item" {
            return itemDeckCountTracker[Int(card.cardId)]!
        } else {
            return mainDeckCountTracker[Int(card.cardId)]!
        }
    }
}
