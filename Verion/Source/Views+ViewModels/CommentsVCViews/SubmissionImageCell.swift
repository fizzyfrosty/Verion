//
//  SubmissionImageCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionImageCell: UITableViewCell {

    @IBOutlet var submissionImageView: FLAnimatedImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindImage(fromViewModel viewModel: SubmissionImageCellViewModel) {
        if viewModel.isGif {
            self.submissionImageView.animatedImage = viewModel.animatedImage
        } else {
            self.submissionImageView.image = viewModel.image
        }
        
    }
    
    deinit {
        #if DEBUG
        print("Deallocated Image View")
        #endif
    }

}
