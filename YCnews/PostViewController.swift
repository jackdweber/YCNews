//
//  PostViewController.swift
//  YCnews
//
//  Created by Jack Weber on 7/11/18.
//  Copyright © 2018 Jack Weber. All rights reserved.
//

import UIKit
import WebKit

class PostViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate  {
    
    var url: URL?
    var post: JSON!
    let api = API(urlString: "https://hacker-news.firebaseio.com/v0/")
    
    var downloadCount: Int = 0
    var rootComment: Comment?
    var commentCount: Int?
    var commentList = [(JSON, Int)]()
    
    let commentRetrievalGroup = DispatchGroup()
    
    let webViewLoadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    @IBOutlet weak var indicatorParent: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    @IBAction func backButtonPressed(_ sender: Any) {
        webView.goBack()
    }
    @IBAction func forwardButtonPressed(_ sender: Any) {
        webView.goForward()
    }
    @IBAction func openComments(_ sender: Any) {
        if commentList.count == 0 {
            indicatorParent.isHidden = false
            indicator.startAnimating()
            commentRetrievalGroup.notify(queue: .main) {
                self.performSegue(withIdentifier: "presentComments", sender: self.post)
                self.indicator.stopAnimating()
                self.indicatorParent.isHidden = true
            }
        } else {
            performSegue(withIdentifier: "presentComments", sender: post)
            indicatorParent.isHidden = true
            indicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewLoadIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewLoadIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: webViewLoadIndicator)
        webView.navigationDelegate = self
        if let location = url {
            webView.load(URLRequest(url: location))
        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            self.commentRetrievalGroup.enter()
            self.rootComment = self.api.getComments(post: self.post)
            self.preorderTraveral(comment: self.rootComment!, level: 0)
            self.commentCount = self.commentList.count
            self.commentRetrievalGroup.leave()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentComments", let vc = segue.destination as? PostDetailViewController {
            vc.post = self.post
            vc.commentList = self.commentList
        }
    }
    
    private func preorderTraveral(comment: Comment, level: Int){
        if comment.data["text"].string != nil {
            commentList.append((comment.data, level))
        }
        for child in comment.children {
            preorderTraveral(comment: child, level: level+1)
        }
    }
    
    

}
