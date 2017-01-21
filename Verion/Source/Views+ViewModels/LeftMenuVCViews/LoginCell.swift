//
//  LoginCell.swift
//  Verion
//
//  Created by Simon Chen on 1/20/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class LoginCell: UITableViewCell {

    @IBOutlet var loginLabel: UILabel!
    
    private let LOGIN_TITLE = "Log In"
    private let LOGOUT_TITLE = "Log Out"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: LoginCellViewModel) {
        self.setLabelTextForIsLoggedIn(isLoggedIn: viewModel.isLoggedIn.value, username: viewModel.username)
        
        _ = viewModel.isLoggedIn.observeNext { [weak self] isLoggedIn in
            self?.setLabelTextForIsLoggedIn(isLoggedIn: isLoggedIn, username: viewModel.username)
        }
    }
    
    private func setLabelTextForIsLoggedIn(isLoggedIn: Bool, username: String) {
        if isLoggedIn == true {
            self.loginLabel.text = self.LOGOUT_TITLE + " (\(username))"
        } else {
            self.loginLabel.text = self.LOGIN_TITLE
        }
    }

}
