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
    
    // Native ad is basically a viewmodel for our ad elements, needs to be set externally
    var nativeAd: APDNativeAd? {
        didSet {
            if nativeAd != nil {
                self.titleLabel.text = nativeAd!.title
                self.subtitleLabel.text = nativeAd!.subtitle
                self.actionLabel.text = nativeAd!.callToActionText
                
                // Image
                self.imageView.layer.borderWidth = 1.0
                self.imageView.layer.borderColor = UIColor.black.cgColor
                self.loadThumbnailIcon(url: nativeAd!.iconImage.url)
                
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
