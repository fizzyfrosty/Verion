//
//  ComposeCommentViewController.swift
//  Verion
//
//  Created by Simon Chen on 1/31/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import MBProgressHUD
import Bond

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

protocol ComposeCommentViewControllerDelegate: class {
    func composeCommentViewControllerSubmittedComment(controller: ComposeCommentViewController, dataModel: ComposeCommentViewControllerDataModel, comment: String)
    func composeCommentViewControllerDidClose(controller: ComposeCommentViewController)
}

class ComposeCommentViewController: UIViewController {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var backgroundViewHeight: NSLayoutConstraint!
    
    var bottomConstraint: NSLayoutConstraint?
    var leadingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    
    let ANIMATE_TIME: TimeInterval = 0.25
    let HIDE_TIME: TimeInterval = 0.5
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var closeButton: UIButton!
    @IBAction func pressedClose(_ sender: Any) {
        
        if self.textView.text != "" {
            self.showConfirmToClose() {
                self.dismissTextView()
            }
        } else {
            self.dismissTextView()
        }
        
    }
    
    @IBOutlet var sendButton: UIButton!
    @IBAction func pressedSend(_ sender: Any) {
        
        // Send to server
        self.submitComment(self.textView.text, submitType: (self.dataModel?.type)!)
    }
    
    // Data model to be set externally
    var dataModel: ComposeCommentViewControllerDataModel?
    weak var rootViewController: UIViewController?
    weak var delegate: ComposeCommentViewControllerDelegate?
    
    var activityIndicator: MBProgressHUD?
    var tapGesture: UITapGestureRecognizer?
    var isShown: Bool = false
    
    // Dependencies
    var dataProvider: DataProviderType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Public Methods
    
    func prepareFrameForShowing() {
        let height = UIScreen.main.bounds.size.height * 0.25
        
        self.backgroundViewHeight.constant = height
        
    }
    
    func showTextView(rootViewController: UIViewController, dataModel: ComposeCommentViewControllerDataModel) {
        self.prepareFrameForShowing()
        self.rootViewController = rootViewController
        self.registerKeyboardNotifications()
        self.dataModel = dataModel
        self.loadData(dataModel: self.dataModel!)
        self.enableButtons()
        
        // FIXME: Animate show
        self.rootViewController?.view.addSubview(self.backgroundView)
        self.backgroundView.alpha = 0
        self.animateShow(duration: self.ANIMATE_TIME) {
            self.textView.becomeFirstResponder()
        }
        
        // Set constraints
        self.bottomConstraint = NSLayoutConstraint.init(item: self.backgroundView, attribute: .bottom, relatedBy: .equal, toItem: rootViewController.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.leadingConstraint = NSLayoutConstraint.init(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: rootViewController.view, attribute: .leading, multiplier: 1, constant: 0)
        self.trailingConstraint = NSLayoutConstraint.init(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: rootViewController.view, attribute: .trailing, multiplier: 1, constant: 0)
        
    
        self.rootViewController?.view.addConstraint(self.bottomConstraint!)
        self.rootViewController?.view.addConstraint(self.leadingConstraint!)
        self.rootViewController?.view.addConstraint(self.trailingConstraint!)
        
        self.isShown = true
    }
    
    func dismissTextView() {
        
        self.animateHide(duration: self.HIDE_TIME) {
            // Remove view and constraints
            self.backgroundView.removeFromSuperview()
            self.removeKeyboardObservers()
            self.isShown = false
            
            self.rootViewController?.view.removeConstraint(self.bottomConstraint!)
            self.rootViewController?.view.removeConstraint(self.leadingConstraint!)
            self.rootViewController?.view.removeConstraint(self.trailingConstraint!)
            
            // Reset the text
            self.textView.text = ""
            
            self.notifyDelegateDidClose()
        }
    }
    
    // MARK: - Keyboard
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Looks for single or multiple taps.
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        self.tapGesture?.cancelsTouchesInView = false
        
        self.rootViewController!.view.addGestureRecognizer(self.tapGesture!)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.rootViewController?.view.removeGestureRecognizer(self.tapGesture!)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.rootViewController!.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            let heightToShift = keyboardSize.height
            self.bottomConstraint?.constant = -heightToShift
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint?.constant = 0
    }
    
    // MARK: - Private Methods
    
    private func animateShow(duration: TimeInterval, completion: @escaping ()->()) {
        UIView.animate(withDuration: duration, animations: { 
            self.backgroundView.alpha = 1.0
        }) { (finished) in
            completion()
        }
    }
    
    private func animateHide(duration: TimeInterval, completion: @escaping ()->()) {
        UIView.animate(withDuration: duration, animations: {
            self.backgroundView.alpha = 0
        }) { (finished) in
            completion()
        }
    }
    
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
    
    private func showErrorAlert() {
        let title = "Error"
        let message = "Failed to submit comment."
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func submitTopLevelComment(_ comment: String) {
        
        self.showActivityIndicator()
        self.disableButtons()
        
        self.dataProvider?.requestSubmitTopLevelComment(subverseName: (self.dataModel?.subverseName)!, submissionId: (self.dataModel?.submissionId)!, comment: comment) { [weak self] error in
            
            self?.hideActivityIndicator()
            
            guard error == nil else {
                // Failure
                self?.showErrorAlert()
                self?.enableButtons()
                return
            }
            
            // Success
            self?.returnCommentAndClose(comment: comment)
        }
    }
    
    private func submitCommentReply(_ comment: String) {
        
        self.showActivityIndicator()
        self.disableButtons()
        
        self.dataProvider?.requestSubmitCommentReply(subverseName: (self.dataModel?.subverseName)!, submissionId: (self.dataModel?.submissionId)!, commentId: (self.dataModel?.commentId)!, comment: comment) { [weak self] error in
            
            self?.hideActivityIndicator()
            
            
            guard error == nil else {
                // Failure
                self?.showErrorAlert()
                self?.enableButtons()
                return
            }
            
            // Success
            self?.returnCommentAndClose(comment: comment)
        }
        
    }
    
    private func returnCommentAndClose(comment: String) {
        ActivityIndicatorProvider.showNotification(message: "Success!", view: (self.rootViewController?.view)!) {
            
            self.notifyDelegateDidSubmitComment(comment: comment)
            self.dismissTextView()
        }
    }
    
    private func showActivityIndicator() {
        self.activityIndicator = ActivityIndicatorProvider.getAndShowProgressHudActivityIndicator(rootViewController: self.rootViewController!)
    }
    
    private func hideActivityIndicator() {
        self.activityIndicator?.hide(animated: true)
    }
    
    private func disableButtons() {
        self.sendButton.isEnabled = false
        self.closeButton.isEnabled = false
        self.textView.isEditable = false
    }
    
    private func enableButtons() {
        self.sendButton.isEnabled = true
        self.closeButton.isEnabled = true
        self.textView.isEditable = true
    }
    
    private func showConfirmToClose(confirmClosure: @escaping()->() ) {
        let title = ""
        let message = "Delete this comment?"
        let confirmAlert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (alertAction) in
            confirmClosure()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmAlert.addAction(deleteAction)
        confirmAlert.addAction(cancelAction)
        
        self.rootViewController!.present(confirmAlert, animated: true, completion: nil)
    }
    
    private func notifyDelegateDidClose() {
        if let _ = self.delegate?.composeCommentViewControllerDidClose(controller: self) {
            
        } else {
            #if DEBUG
            print("Warning: ComposeCommentViewController's delegate may not be set.")
            #endif
        }
    }
    
    private func notifyDelegateDidSubmitComment(comment: String) {
        if let _ = self.delegate?.composeCommentViewControllerSubmittedComment(controller: self, dataModel: self.dataModel!, comment: comment) {
            
        } else {
            #if DEBUG
                print("Warning: ComposeCommentViewController's delegate may not be set.")
            #endif
        }
    }
}














