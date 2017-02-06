//
//  NativeAdViewController.swift
//  Verion
//
//  Created by Simon Chen on 2/5/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Appodeal

class NativeAdViewController: UIViewController {

    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var actionLabel: UILabel!
    
    @IBOutlet var adChoiceView: UIView!
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var callToActionButtonWidth: NSLayoutConstraint!
    
    
    // Native ad is basically a viewmodel for our ad elements, needs to be set externally
    var nativeAd: APDNativeAd? {
        didSet {
            if nativeAd != nil {
                self.titleLabel.text = nativeAd!.title
                self.subtitleLabel.text = nativeAd!.subtitle
                self.actionLabel.text = nativeAd!.callToActionText
                
                // Set button width
                var buttonWidth: CGFloat = 0
                if self.actionLabel.text != "" {
                    buttonWidth = self.getCallToActionButtonWidth(fromString: self.actionLabel.text!)
                    
                } else {
                    buttonWidth = 0
                }
                callToActionButtonWidth.constant = buttonWidth
                
                // Image
                self.imageView.layer.borderWidth = 1.0
                self.imageView.layer.borderColor = UIColor.black.cgColor
                
                if self.imageView.image == nil {
                    if nativeAd?.iconImage.url != nil {
                        self.loadThumbnailIcon(url: nativeAd!.iconImage.url)
                    }
                }
                
                self.loadAdChoiceView(view: nativeAd!.adChoicesView)
                
                self.backgroundView.backgroundColor = UIColor.white
                nativeAd!.attach(to: self.backgroundView, viewController: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.loadNativeAd()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attachNativeAd(toParentView parentView: UIView, inViewController rootViewController: UIViewController) {
        self.nativeAd?.attach(to: self.backgroundView, viewController: rootViewController)
        
        let leading = NSLayoutConstraint.init(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: 0)
        
        parentView.addConstraints([leading, trailing])
    }
    
    private func getCallToActionButtonWidth(fromString buttonTitle: String) -> CGFloat {
        var width: CGFloat = 0
        let margins: CGFloat = 10.0
        
        let size = CellHeightCalculator.sizeForText(text: buttonTitle, font: UIFont.boldSystemFont(ofSize: 14.0), maxSize: CGSize(width: 200.0, height: 50))
        width = size.width + margins
        
        return width
    }
    
    private func loadThumbnailIcon(url: URL) {
        
        DispatchQueue.global(qos: .background).async {
            let thumbnailImage = ImageDownloader.downloadImage(urlString: url.absoluteString)
            
            if thumbnailImage != nil {
                DispatchQueue.main.async {
                    self.imageView.image = thumbnailImage
                }
            }
        }
    }
    
    private func loadAdChoiceView(view: UIView?) {
        if view != nil {
            self.adChoiceView.addSubview(view!)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
