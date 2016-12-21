//
//  ProgressIndicatorCell.swift
//  Verion
//
//  Created by Simon Chen on 12/20/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class ProgressIndicatorCell: UITableViewCell {

    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: ProgressIndicatorCellViewModel) {
        _ = viewModel.progress.observeNext { [weak self] (progress) in
            self?.progressBar.progress = Float(progress)
            self?.progressLabel.text = "downloading...\(Int(progress * 100))%"
        }
    }

}
