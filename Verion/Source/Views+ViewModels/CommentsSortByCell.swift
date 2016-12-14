//
//  CommentsSortByCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class CommentsSortByCell: UITableViewCell {

    @IBOutlet var sortByButton: UIButton!
    
    // TODO: These are for v1 api implementation
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
