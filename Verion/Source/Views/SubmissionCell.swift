//
//  SubmissionCell.swift
//  Verion
//
//  Created by Simon Chen on 11/30/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class SubmissionCell: UITableViewCell {
    
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var thumbnailLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var voteSeparatedCountLabel: UILabel!
    
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!

    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var submittedByUserLabel: UILabel!
    @IBOutlet var submittedToSubverseLabel: UILabel!
    
    
    
    let BORDER_WIDTH: CGFloat = 1
    let BORDER_COLOR: CGColor = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.borderWidth = self.BORDER_WIDTH
        self.layer.borderColor = self.BORDER_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: SubmissionCellViewModel) {
        
    }

}
