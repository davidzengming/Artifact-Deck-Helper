//
//  ViewController.swift
//  ArtifactMe
//
//  Created by David Zeng on 11/22/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import CoreData

extension UIView{
    func blink() {
        self.alpha = 0.2
        UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse, .allowUserInteraction], animations: {self.alpha = 1.0}, completion: nil)
    }
}

class LoginViewController: UIViewController, UITextViewDelegate {
    private var cards = [Card]()
    private var cardHashMap = [Int: Card]()
    private let dispatchGroup = DispatchGroup()
    private var isLoaded = false
    @IBOutlet weak var wallpaper: UIImageView!
    @IBOutlet weak var loadingStatusButton: UIButton!
    @IBOutlet weak var statusLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingStatusButton.isEnabled = false
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.loadingStatusButton.setTitle("Connecting to Server...",for: .normal)
            }
            
            CardParser.parseFromValveAPI()
            
            DispatchQueue.main.async {
                self.statusLog.text = "\nCONNECTED" + self.statusLog.text
                self.loadingStatusButton.setTitle("Loading cards from database... ",for: .normal)
            }
            
            self.loadCardsFromCoreData()
            self.markSignatureCards()
            
            DispatchQueue.main.async {
                self.statusLog.text = "\nLOADED CARDS" + self.statusLog.text
                self.isLoaded = true
                self.loadingStatusButton.isEnabled = true
                self.loadingStatusButton.setTitle("Tap to start",for: .normal)
                self.loadingStatusButton.blink()
            }
        }
    }
    
    @IBAction func clickOnTapToStart(_ sender: Any) {
        if isLoaded == true {
            performSegue(withIdentifier: "showApp", sender: self)
        }
    }
    
    func markSignatureCards() {
        for card in cards {
            if card.cardType == "Hero" {
                for reference in card.references?.allObjects as! [Reference] {
                    guard let referenceCard = cardHashMap[Int(reference.cardId)] as Card? else {
                        continue
                    }
                    if referenceCard.cardType != "Passive Ability" && referenceCard.cardType != "Ability" {
                        referenceCard.isSignature = true
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let barViewControllers = segue.destination as! UITabBarController
        
        let navigationController = barViewControllers.viewControllers?[0] as! UINavigationController
        let cardGalleryController =  navigationController.viewControllers[0] as! CardTableViewController
        cardGalleryController.initCards(with: cards, cardHashMap: cardHashMap)
        
        let deckBuilderController = barViewControllers.viewControllers?[1] as! DeckBuilderViewController
        deckBuilderController.initCards(with: cards, cardHashMap: cardHashMap)
    }

    private func loadCardsFromCoreData() {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CardSet")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [CardSet] {
                for card in data.cards! {
                    let newCard = card as! Card
                    cardHashMap[Int(newCard.cardId)] = newCard
                    if newCard.cardType != "Passive Ability" && newCard.cardType != "Ability" {
                        cards += [newCard]
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
}

