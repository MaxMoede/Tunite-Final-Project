//
//  profileCell.swift
//  Final Project
//
//  Created by Max Moede on 3/5/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit

class profileCell: UITableViewCell {


    @IBOutlet weak var picView: UIView!
    @IBOutlet weak var instrumentL: UILabel!
    @IBOutlet weak var profPic: UIImageView!
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
