//
//  DeckBuilderViewController.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/12/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import CoreData

class DeckBuilderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    

    @IBOutlet weak var colorTrackerCollectionView: UICollectionView!
    @IBOutlet weak var galleryPrevPageButton: UIButton!
    @IBOutlet weak var galleryNextPageButton: UIButton!
    @IBOutlet weak var heroesCollectionView: UICollectionView!
    @IBOutlet weak var deckListTableView: UITableView!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var gallerySearchBar: UISearchBar!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    private var cards = [Card]()
    private var cardsPerGalleryPage = 10
    private var currentCardsArray = [Card]()
    private var rowSelected: Int?
    private var cardHashMap = [Int:Card]()
    private let deck = Deck()
    private var galleryPageCounter = 0
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.backgroundColor = UIColor(red: 23/255.0, green: 23/255.0, blue: 25/255.0, alpha: 1)
        setUpCards()
        updatePaginationButtons()
        
        deckListTableView.rowHeight = self.view.frame.height * 0.1
        deckListTableView.estimatedRowHeight = self.view.frame.height * 0.1
        deckListTableView.reloadData()
        
        heroesCollectionView.isScrollEnabled = false
        galleryCollectionView.isScrollEnabled = false
        colorTrackerCollectionView.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        galleryCollectionView.addGestureRecognizer(swipeLeft)
        galleryCollectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            if galleryPageCounter == 0 {
                return
            }
            swipeLeft()
        case UISwipeGestureRecognizer.Direction.left:
            if galleryPageCounter == Int(ceil(Double(currentCardsArray.count) / Double(cardsPerGalleryPage))) - 1 {
                return
            }
            swipeRight()
        default:
            break
        }
    }
    
    private func swipeLeft() {
        galleryPageCounter -= 1
        updatePaginationButtons()
        galleryCollectionView.reloadData()
    }
    
    private func swipeRight() {
        galleryPageCounter += 1
        updatePaginationButtons()
        galleryCollectionView.reloadData()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        view.frame.origin.y = -view.frame.height * 0.25
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.gallerySearchBar.endEditing(true)
        view.frame.origin.y = 0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.gallerySearchBar.endEditing(true)
        view.frame.origin.y = 0
    }
    
    func initCards(with cards: [Card], cardHashMap: [Int:Card]) {
        self.cards = cards
        self.cardHashMap = cardHashMap
    }
    
    private func setUpCards() {
        cards = cards.filter({ card -> Bool in
            return (card.isSignature == false)
        })
        
        cards = cards.sorted {
            if $0.isBlue != $1.isBlue {
                return $0.isBlue == true
            } else if $0.isRed != $1.isRed {
                return $0.isRed == true
            } else if $0.isGreen != $1.isGreen {
                return $0.isGreen == true
            } else if $0.isBlack != $1.isBlack {
                return $0.isBlack == true
            } else {
                if $0.cardType != $1.cardType {
                    if $0.cardType == "Hero" {
                        return true
                    }
                    if $1.cardType == "Hero" {
                        return false
                    }
                    return $0.cardType! < $1.cardType!
                } else {
                    return $0.cardName!["english"]! < $1.cardName!["english"]!
                }
            }
        }
        
        currentCardsArray = cards
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.view.frame.size.height * 0.05 //Choose your custom row height
    }
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel previous task if any
        pendingRequestWorkItem?.cancel()
        
        // Replace previous task with a new one
        let currentWorkItem = DispatchWorkItem {
            if searchText == "" {
                self.currentCardsArray = self.cards
                self.updatePaginationButtons()
                self.galleryCollectionView.reloadData()
                return
            }
            
            self.currentCardsArray = self.cards.filter({ card -> Bool in
                return (card.cardName!["english"]?.localizedCaseInsensitiveContains(searchText))!
            })
            
            self.galleryPageCounter = 0
            self.updatePaginationButtons()
            self.galleryCollectionView.reloadData()
        }
        
        // Execute task in 0.75 seconds (if not cancelled !)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: currentWorkItem)
    }
    
    override func viewWillLayoutSubviews() {
        let height = self.view.frame.size.height
        //let horizontalClass = self.traitCollection.horizontalSizeClass
        let verticalClass = self.traitCollection.verticalSizeClass
        
        let heroesFlowLayout = heroesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let galleryFlowLayout = galleryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let colorFlowLayout = colorTrackerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        colorFlowLayout.minimumLineSpacing = 0
        colorFlowLayout.minimumInteritemSpacing = 0
        
        if verticalClass == .compact {
            let scaledHeightForHeroes = height * 0.1
            heroesFlowLayout.estimatedItemSize = CGSize(width: scaledHeightForHeroes, height: scaledHeightForHeroes)
            heroesFlowLayout.minimumInteritemSpacing = scaledHeightForHeroes * 0.2
            
            let scaledHeightForColors = self.view.frame.size.height * 0.1
            colorFlowLayout.estimatedItemSize = CGSize(width: scaledHeightForColors, height: scaledHeightForColors)
            
            let scaledHeightForCards = self.view.frame.size.height * 0.2 * 0.9
            galleryFlowLayout.estimatedItemSize = CGSize(width: scaledHeightForCards / 1.618, height: scaledHeightForCards)
            galleryFlowLayout.minimumInteritemSpacing = scaledHeightForCards * 0.1
        } else {
            let scaledHeightForHeroes = height * 0.05
            heroesFlowLayout.estimatedItemSize = CGSize(width: scaledHeightForHeroes, height: scaledHeightForHeroes)
            heroesFlowLayout.minimumInteritemSpacing = scaledHeightForHeroes * 0.2
            
            let scaledHeightForColors = self.view.frame.size.height * 0.05
            colorFlowLayout.estimatedItemSize = CGSize(width: scaledHeightForColors, height: scaledHeightForColors)

            let scaledHeightForCards = self.view.frame.size.height * 0.2 / 2 * 0.9
            galleryFlowLayout.estimatedItemSize = CGSize(width: scaledHeightForCards / 1.618, height: scaledHeightForCards)
            galleryFlowLayout.minimumInteritemSpacing = scaledHeightForCards * 0.085
        }
        
        super.viewWillLayoutSubviews()
        heroesCollectionView.collectionViewLayout.invalidateLayout()
        galleryCollectionView.collectionViewLayout.invalidateLayout()
        colorTrackerCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func updatePaginationButtons() {
        if galleryPageCounter == 0 {
            galleryPrevPageButton.isHidden = true
        } else {
            galleryPrevPageButton.isHidden = false
        }
        
        if galleryPageCounter < Int(ceil(Double(currentCardsArray.count) / Double(cardsPerGalleryPage))) - 1 {
            galleryNextPageButton.isHidden = false
        } else {
            galleryNextPageButton.isHidden = true
        }
    }
    
    @IBAction func onClickGalleryPrev(_ sender: Any) {
        swipeLeft()
    }
    
    @IBAction func onClickGalleryNext(_ sender: Any) {
        swipeRight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deck.getCardCount()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deck.removeCardFromDeck(at: indexPath.row, with: cardHashMap)
        colorTrackerCollectionView.reloadData()
        deckListTableView.reloadData()
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DeckListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DeckListTableViewCell else {
            fatalError("The dequeue cell is not an instance of DeckListTableViewCell")
        }
        
        let card = deck.getDeckArray()[indexPath.row]
        cell.cardName.text = card.cardName?["english"]
        
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if card.isRed {
            cell.backgroundColor = UIColor(red: 154/255.0, green: 43/255.0, blue: 60/255.0, alpha: 1)
        } else if card.isBlue {
            cell.backgroundColor = UIColor(red: 17/255.0, green: 59/255.0, blue: 81/255.0, alpha: 1)
        } else if card.isGreen {
            cell.backgroundColor = UIColor(red: 95/255.0, green: 120/255.0, blue: 69/255.0, alpha: 1)
        } else if card.isBlack {
            cell.backgroundColor = UIColor(red: 47/255.0, green: 47/255.0, blue: 55/255.0, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(red: 210/255.0, green: 144/255.0, blue: 49/255.0, alpha: 1)
        }
        
        if card.miniImage!["local"] != nil {
            cell.miniCardImage.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + card.miniImage!["local"]!)!.path)!
        } else {
            cell.miniCardImage.image = nil
        }
        
        if card.cardType == "Creep" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "creep")
        } else if card.cardType == "Spell" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "spell")
        } else if card.cardType == "Improvement" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "improvement")
        } else {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "health")
        }
        
        cell.cardCount.text = String(deck.getCount(forCard: card))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let verticalClass = self.traitCollection.verticalSizeClass
        
        if collectionView == heroesCollectionView {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: section))
            let combinedItemWidth = (numberOfItems * flowLayout.estimatedItemSize.width) + ((numberOfItems)  * flowLayout.minimumInteritemSpacing)
            let padding = (collectionView.frame.width - combinedItemWidth) / 2
            
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        } else if collectionView == colorTrackerCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            // 2 rows
            var numberOfItems = collectionView.numberOfItems(inSection: section)
            
            if verticalClass != .compact && numberOfItems > cardsPerGalleryPage / 2 {
                numberOfItems = Int(ceil(Double(numberOfItems) / Double(2)))
            }
            
            let combinedItemWidth = (CGFloat(numberOfItems) * flowLayout.estimatedItemSize.width) + (CGFloat(numberOfItems)  * flowLayout.minimumInteritemSpacing)
            let padding = (collectionView.frame.width - combinedItemWidth) / 2
            
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryCollectionView {
            let selectedCard = currentCardsArray[galleryPageCounter * cardsPerGalleryPage + indexPath.item]
            deck.addToDeck(selectedCard, with: cardHashMap)
        } else if collectionView == colorTrackerCollectionView {
            return
        } else {
            deck.removeHeroFromDeck(at: indexPath.item, with: cardHashMap)
        }
        
        colorTrackerCollectionView.reloadData()
        deckListTableView.reloadData()
        heroesCollectionView.reloadData()
        
        if collectionView == galleryCollectionView {
            let selectedCard = currentCardsArray[galleryPageCounter * cardsPerGalleryPage + indexPath.item]
            let index = deck.findRowIndexWith(selectedCard)
            if index != -1 {
                let indexPath = IndexPath(row: index, section: 0)
                deckListTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            } else {
                let indexPath = IndexPath(row: deck.getCardCount() - 1, section: 0)
                deckListTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
        updatePaginationButtons()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            if galleryPageCounter < Int(ceil(Double(currentCardsArray.count) / Double(cardsPerGalleryPage))) - 1 {
                return cardsPerGalleryPage
            } else {
                return currentCardsArray.count % cardsPerGalleryPage
            }
        } else if collectionView == colorTrackerCollectionView {
            return deck.getColorCount().count
        } else {
            return deck.getHeroesCount()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        if collectionView == galleryCollectionView {
            let cellIdentifier = "miniCardCell"
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? GalleryCollectionViewCell else {
                fatalError("The dequeue cell is not an instance of CardTableViewCell")
            }
            
            let card = currentCardsArray[galleryPageCounter * cardsPerGalleryPage + indexPath.item]
            
            if card.largeImage!["local"] != nil {
                cell.miniCardImage.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + card.largeImage!["local"]!)!.path)!
            } else {
                cell.miniCardImage.image = nil
            }
            
            return cell
        } else if collectionView == colorTrackerCollectionView {
            let cellIdentifier = "colorViewCell"
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ColorTrackerCollectionViewCell else {
                fatalError("The dequeue cell is not an instance of ColorTrackerCollectionViewCell")
            }
            
            let colors = deck.getColorCount()
            
            switch indexPath.item {
            case 0:
                cell.colorCount.text = String(colors["Blue"]!)
                cell.backgroundColor = UIColor(red: 17/255.0, green: 59/255.0, blue: 81/255.0, alpha: 1)
            case 1:
                cell.colorCount.text = String(colors["Black"]!)
                cell.backgroundColor = UIColor(red: 47/255.0, green: 47/255.0, blue: 55/255.0, alpha: 1)
            case 2:
                cell.colorCount.text = String(colors["Red"]!)
                cell.backgroundColor = UIColor(red: 154/255.0, green: 43/255.0, blue: 60/255.0, alpha: 1)
            case 3:
                cell.colorCount.text = String(colors["Green"]!)
                cell.backgroundColor = UIColor(red: 95/255.0, green: 120/255.0, blue: 69/255.0, alpha: 1)
            default:
                print("Error")
            }
            
            return cell
            
            
        } else {
            let cellIdentifier = "heroesCardCell"
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HeroesCollectionViewCell else {
                fatalError("The dequeue cell is not an instance of heroesCardCellViewCell")
            }
            
            let heroesDeck = deck.getHeroesDeck()
            if indexPath.item >= heroesDeck.count {
                cell.heroesCardImage.image = #imageLiteral(resourceName: "questionMark")
                return cell
            }
            
            let card = deck.getHeroesDeck()[indexPath.item]
            if card.ingameImage!["local"] != nil {
                cell.heroesCardImage.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + card.ingameImage!["local"]!)!.path)!
            } else {
                cell.heroesCardImage.image = #imageLiteral(resourceName: "questionMark")
            }
            
            return cell
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
