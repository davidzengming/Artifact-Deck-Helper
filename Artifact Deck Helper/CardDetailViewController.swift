//
//  CardDetailViewController.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/6/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    private let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    var card: Card?
    var cardHashMap: [Int: Card]?
    var cardAndReferencesArray: [Card] = []
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 23/255.0, green: 23/255.0, blue: 25/255.0, alpha: 1)
        
        cardImage.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + card!.largeImage!["local"]!)!.path)!
        
        cardAndReferencesArray.append(card!)
        for reference in card!.references?.allObjects as! [Reference] {
            guard let referenceCard = cardHashMap![Int(reference.cardId)] else {
                print(Int(reference.cardId), " is not found.")
                continue
            }
            
            print(referenceCard)
            
            if referenceCard.cardType != "Passive Ability" && referenceCard.cardType != "Ability" {
                cardAndReferencesArray.append(referenceCard)
            }
        }
        updateArrowButtons()
        
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            if currentIndex == 0 {
                return
            }
            swipeLeft()
        case UISwipeGestureRecognizer.Direction.left:
            
            if currentIndex == cardAndReferencesArray.count - 1 {
                return
            }
            swipeRight()
        default:
            break
        }
    }
    
    private func swipeLeft() {
        currentIndex -= 1
        cardImage.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + cardAndReferencesArray[currentIndex].largeImage!["local"]!)!.path)!
        updateArrowButtons()
    }
    
    private func swipeRight() {
        currentIndex += 1
        cardImage.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + cardAndReferencesArray[currentIndex].largeImage!["local"]!)!.path)!
        updateArrowButtons()
    }
    
    @IBAction func onClickLeftArrowButton(_ sender: Any) {
        swipeLeft()
    }
    
    @IBAction func onClickRightArrowButton(_ sender: Any) {
        swipeRight()
    }
    
    private func updateArrowButtons() {
        if currentIndex == 0 {
            leftArrowButton.isHidden = true
        } else {
            leftArrowButton.isHidden = false
        }
        
        if currentIndex == cardAndReferencesArray.count - 1 {
            rightArrowButton.isHidden = true
        } else {
            rightArrowButton.isHidden = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
