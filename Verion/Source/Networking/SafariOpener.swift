//
//  SafariOpener.swift
//  Verion
//
//  Created by Simon Chen on 2/25/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import SafariServices

class SafariOpener: NSObject {

    static func openUrlInSafari(_ url: URL) {
        guard #available(iOS 10, *) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    static func openUrlInSafariViewController(_ url: URL, rootViewController: UIViewController) {
        let safariViewController = SFSafariViewController.init(url: url)
        rootViewController.present(safariViewController, animated: true) {
        }
    }
}
