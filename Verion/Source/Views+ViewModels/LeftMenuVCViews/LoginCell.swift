//
//  LoginCell.swift
//  Verion
//
//  Created by Simon Chen on 1/20/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

class LoginCell: UITableViewCell {

    @IBOutlet var loginLabel: UILabel!
    
    private let LOGIN_TITLE = "Login"
    private let LOGOUT_TITLE = "Logout"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: LoginCellViewModel) {
        // FIXME: Implement
        if viewModel.isLoggedIn == true {
            self.loginLabel.text = self.LOGOUT_TITLE + " (\(viewModel.username))"
        } else {
            self.loginLabel.text = self.LOGIN_TITLE
        }
    }

}
