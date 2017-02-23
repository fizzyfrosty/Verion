//
//  ProgressIndicatorCell.swift
//  Verion
//
//  Created by Simon Chen on 12/20/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

class ProgressIndicatorCell: UITableViewCell {

    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    
    
    private var bgColor: UIColor {
        get {
            return sfxManager!.bgColor1
        }
    }
    
    private var txtColor: UIColor {
        get {
            return self.sfxManager!.textColor
        }
    }
    
    private weak var sfxManager: SFXManager?
    private var bindings: [Disposable] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: ProgressIndicatorCellViewModel, sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        self.setUIColors()
        
        self.bindings.append( viewModel.progress.observeNext { [weak self] (progress) in
            self?.progressBar.progress = Float(progress)
            self?.progressLabel.text = "downloading...\(Int(progress * 100))%"
        })
    }
    
    private func setUIColors() {
        self.contentView.backgroundColor = self.bgColor
        self.progressLabel.textColor = self.txtColor
    }
    
    override func prepareForReuse() {
        self.resetBindings()
    }
    
    private func resetBindings() {
        for binding in self.bindings {
            binding.dispose()
        }
        
        self.bindings.removeAll()
    }
    
    deinit {
        #if DEBUG
        print("Deallocated a progress cell")
        #endif
    }

}
