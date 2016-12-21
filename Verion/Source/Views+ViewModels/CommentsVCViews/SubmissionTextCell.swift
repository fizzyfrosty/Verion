//
//  SubmissionTextCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionTextCell: UITableViewCell {
    @IBOutlet var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.textView.isScrollEnabled = false
    }
    
    func bind(toViewModel viewModel: SubmissionTextCellViewModel) {
        self.textView.attributedText = viewModel.attributedTextString
    }

}
