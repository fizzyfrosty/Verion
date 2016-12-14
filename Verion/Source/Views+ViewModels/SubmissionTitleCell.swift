//
//  SubmissionTitleCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionTitleCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var separatedVoteCountLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var timeAndSubverseLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
