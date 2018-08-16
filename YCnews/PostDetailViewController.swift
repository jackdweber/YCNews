//
//  PostDetailViewController.swift
//  YCnews
//
//  Created by Jack Weber on 7/6/18.
//  Copyright © 2018 Jack Weber. All rights reserved.
//

import UIKit

class PostDetailViewController: UITableViewController {
    
    var post: JSON!
    
    var offset: Int!
    let offsetLength = 6;
    
    let api = API(urlString: "https://hacker-news.firebaseio.com/v0/")
    var commentList = [(JSON, Int)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = tan
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableView Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + commentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let vfl = EasyVFL(parentView: cell)
        cell.backgroundColor = tan
        
        var titleLabel = UILabel()
        if let tagged = cell.viewWithTag(100) as? UILabel {
            titleLabel = tagged
        } else {
            titleLabel.tag = 100
        }
        titleLabel.font = titleLabel.font.withSize(24)
        vfl.addView(name: "title", view: titleLabel)
        
        var voteLabel = UILabel()
        if let tagged = cell.viewWithTag(101) as? UILabel {
            voteLabel = tagged
        } else {
            voteLabel.tag = 101
        }
        vfl.addView(name: "vote", view: voteLabel)
        
        let width = indexPath.row == 0 ? 0 : (offsetLength * (commentList[indexPath.row - 1].1 - 1))
        var offsetView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: Int(cell.frame.height)))
        if let tagged = cell.viewWithTag(102) {
            offsetView = tagged
        } else {
            offsetView.tag = 102
        }
        offsetView.backgroundColor = orange
        vfl.addView(name: "offset", view: offsetView)
        
        vfl.addVFL(items: ["H:|-(==\(width - offsetLength))-[offset(==\(offsetLength))]-[title]-|",
                           "H:|-[vote]-(>=1)-|",
                           "V:|[offset]|",
                           "V:|-[title]-[vote]-|"])
        
        if indexPath.row == 0 {
            titleLabel.text = post["title"].string
            if commentList.count == 0 {
                titleLabel.text = "It's empty in here..."
            }
            titleLabel.numberOfLines = 3
            voteLabel.text = ""
            return cell
        }
        
        titleLabel.numberOfLines = 100
        titleLabel.font = titleLabel.font.withSize(10)
        
        titleLabel.attributedText = NSAttributedString(string: commentList[indexPath.row - 1].0["text"].string!)
        voteLabel.text = commentList[indexPath.row - 1].0["score"].string
        
        return cell
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
