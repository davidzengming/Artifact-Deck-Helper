//
//  CardTableViewController.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import CoreData

class CardTableViewController: UITableViewController, UISearchBarDelegate {
    private var cards = [Card]()
    private var currentCardsArray = [Card]()
    private var rowSelected: Int?
    private var cardHashMap = [Int: Card]()
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = self.tableView.frame.height * 0.05
        self.tableView.estimatedRowHeight = self.tableView.frame.height * 0.05
        self.tableView.reloadData()
        setUpCards()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.view.frame.size.height * 0.05 //Choose your custom row height
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       self.searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func initCards(with cards: [Card], cardHashMap: [Int:Card]) {
        self.cards = cards
        self.cardHashMap = cardHashMap
    }
    
    private func setUpCards() {
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
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pendingRequestWorkItem?.cancel()
        
        // Replace previous task with a new one
        let currentWorkItem = DispatchWorkItem {
            if searchText == "" {
                self.currentCardsArray = self.cards
                self.tableView.reloadData()
                return
            }
            
            self.currentCardsArray = self.cards.filter({ card -> Bool in
                return (card.cardName!["english"]?.localizedCaseInsensitiveContains(searchText))!
            })
            
            self.tableView.reloadData()
        }
        
        // Execute task in 0.75 seconds (if not cancelled !)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: currentWorkItem)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let ctrl = segue.destination as! CardDetailViewController
            ctrl.card = currentCardsArray[rowSelected!]
            ctrl.cardHashMap = cardHashMap
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCardsArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CardTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CardTableViewCell else {
            fatalError("The dequeue cell is not an instance of CardTableViewCell")
        }
        
        let card = currentCardsArray[indexPath.row]
        cell.cardNameLabel.text = card.cardName?["english"]
        
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
        
        if card.cardType == "Creep" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "creep")
        } else if card.cardType == "Spell" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "spell")
        } else if card.cardType == "Improvement" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "improvement")
        } else if card.cardType == "Hero" {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "hero")
        } else {
            cell.cardTypeImage.image = #imageLiteral(resourceName: "health")
        }
        
        if card.miniImage!["local"] != nil {
            cell.cardImageView.image = UIImage(contentsOfFile: URL(string: docDir.absoluteString + card.miniImage!["local"]!)!.path)!
        } else {
            cell.cardImageView.image = nil
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
