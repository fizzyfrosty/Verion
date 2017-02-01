//
//  ComposeCommentViewController.swift
//  Verion
//
//  Created by Simon Chen on 1/31/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

enum CommentResponseType {
    case reply
    case topLevelComment
}

struct ComposeCommentViewControllerDataModel {
    var type: CommentResponseType = .topLevelComment
    var username = ""
    var subverseName = ""
    var submissionId: Int64 = -1
    var commentId: Int64 = -1
}

protocol ComposeCommentViewControllerDelegate {
    func composeCommentViewControllerSubmittedComment(controller: ComposeCommentViewController, comment: String)
    func composeCommentViewControllerDidClose(controller: ComposeCommentViewController)
}

class ComposeCommentViewController: UIViewController {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var textView: UITextView!
    
    @IBAction func pressedClose(_ sender: Any) {
    }
    
    @IBAction func pressedSend(_ sender: Any) {
        
        // Send to server
        self.submitComment(self.textView.text)
    }
    
    // Data model to be set externally
    var dataModel: ComposeCommentViewControllerDataModel?
    
    weak var delegate: ComposeCommentViewControllerDelegate?
    
    // Dependencies
    var dataProvider: DataProviderType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundSettings()
        self.loadData(dataModel: self.dataModel!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    
    private func setBackgroundSettings() {
        self.backgroundView.layer.borderWidth = 1.0
        self.backgroundView.layer.borderColor = UIColor.white.cgColor
        
        self.textView.clipsToBounds = true
        self.textView.layer.cornerRadius = 5.0
    }
    
    private func loadData(dataModel: ComposeCommentViewControllerDataModel) {
        
        self.usernameLabel.text = dataModel.username
        
        // Add warning if comment ID is not supplied when type is comment reply
        if dataModel.type == .reply && dataModel.commentId == -1 {
            print("Warning: Type is Comment Replies, but no Comment ID is supplied.")
        }
    }
    
    private func submitComment(_ comment: String, submitType: CommentResponseType) {
        
        switch submitType {
        case .topLevelComment:
            self.submitTopLevelComment(comment)
        case .reply:
            self.submitCommentReply(comment)
        }
    }
    
    private func submitTopLevelComment(_ comment: String) {
        self.dataProvider?.requestSubmitTopLevelComment(subverseName: (self.dataModel?.subverseName)!, submissionId: (self.dataModel?.submissionId)!, comment: comment) { [weak self] error in
            
        }
    }
    
    private func submitCommentReply(_ comment: String) {
        
        self.dataProvider?.requestSubmitCommentReply(subverseName: (self.dataModel?.subverseName)!, submissionId: (self.dataModel?.submissionId)!, commentId: (self.dataModel?.commentId)!, comment: comment) { error in
            
            
        }
        
    }
}














