//
//  DeckListTableViewCell.swift
//  ArtifactMe
//
//  Created by David Zeng on 12/21/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

class DeckListTableViewCell: UITableViewCell {
    @IBOutlet weak var miniCardImage: UIImageView!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var cardCount: UILabel!
    @IBOutlet weak var cardTypeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
