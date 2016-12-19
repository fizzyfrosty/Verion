//
//  WebViewController.swift
//  Verion
//
//  Created by Simon Chen on 12/18/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate, WebViewProgressDelegate {

    @IBOutlet var webView: UIWebView!
    
    var progressProxy = WebViewProgress()
    var progressView: WebViewProgressView?
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    var link = ""
    
    
    @IBAction func refreshAction(_ sender: Any) {
        self.reload()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.webView.goBack()
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        self.webView.goForward()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.progressView = self.getProgressView(webView: self.webView, progressProxy: self.progressProxy)
        self.navigationController?.navigationBar.addSubview(self.progressView!)
        
        self.loadLink()
    }
    
    func loadLink() {
        let url = URL.init(string: self.link)
        let urlRequest = URLRequest.init(url: url!)
        webView.loadRequest(urlRequest)
    }
    
    func reload() {
        self.webView.reload()
    }
    
    func getProgressView(webView: UIWebView, progressProxy: WebViewProgress) -> WebViewProgressView{
        webView.delegate = progressProxy
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
        
        let progressBarHeight: CGFloat = 2.0
        let navigationBarBounds = self.navigationController!.navigationBar.bounds
        let barFrame = CGRect(x: 0, y: navigationBarBounds.size.height - progressBarHeight, width: navigationBarBounds.width, height: progressBarHeight)
        let progressView = WebViewProgressView.init(frame: barFrame)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        progressView.progressBarView.backgroundColor = UIColor.white
        
        return progressView
    }
    
    func webViewProgress(_ webViewProgress: WebViewProgress, updateProgress progress: Float) {
        self.progressView?.setProgress(progress, animated: true)
    }

    // Error, no connection?
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //self.progressView?.setProgress(0, animated: true)
        
        /*
        self.errorLabel.isHidden = false
        self.errorLabel.text = error.localizedDescription*/
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if webView.canGoBack {
            self.backButton.isEnabled = true
        } else {
            self.backButton.isEnabled = false
        }
        
        if webView.canGoForward {
            self.forwardButton.isEnabled = true
        } else {
            self.forwardButton.isEnabled = false
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.webView.stopLoading()
        self.progressView?.removeFromSuperview()
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
