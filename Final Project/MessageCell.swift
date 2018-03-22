//
//  MessageCell.swift
//  Final Project
//
//  Created by Max Moede on 3/20/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var nameL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
