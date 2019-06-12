//
//  NewsTableViewCell.swift
//  Module-2
//
//  Created by Jan Rombout on 11/06/2019.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import Parse

class NewsTableViewCell: PFTableViewCell {

    @IBOutlet var titleLabel:UILabel?
    @IBOutlet var excerptLabel:UILabel?
    @IBOutlet var thumbnailView:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
