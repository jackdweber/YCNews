//
//  ViewController.swift
//  YCnews
//
//  Created by Jack Weber on 7/2/18.
//  Copyright © 2018 Jack Weber. All rights reserved.
//

import UIKit

let orange = UIColor(red: 252/255, green: 102/255, blue: 33/255, alpha: 1.0)
let tan = UIColor(red: 246/255, green: 246/255, blue: 239/255, alpha: 1.0)

class ViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
    
    let api = API(urlString: "https://hacker-news.firebaseio.com/v0/")
    var json: JSON!
    var count = 0;
    var totalCount = 30;
    var stories = [Int: JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.backgroundColor = tan
        performSelector(inBackground: #selector(fetchData), with: nil)
        tableView.prefetchDataSource = self
        tableView.showsVerticalScrollIndicator = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPost", let vc = segue.destination as? PostViewController,
            let postInfo = sender as? JSON,
            let urlString = postInfo["url"].string,
            let url = URL(string: urlString)
        {
            vc.url = url
            vc.post = postInfo
        }
    }
    
    //Table functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCount
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = json.array, let story = stories[items[indexPath.row].int!] else {
            return
        }
        performSegue(withIdentifier: "presentPost", sender: story)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        let vfl = EasyVFL(parentView: cell.contentView)
        cell.contentView.backgroundColor = tan
        if indexPath.row >= count {
            return cell
        }
        guard let items = json.array, let story = stories[items[indexPath.row].int!], let title = story["title"].string else {
            return cell
        }
        
        //Add Title
        let titleLabelAttributes: (UILabel) -> () = {
            $0.text = title
            $0.numberOfLines = 3
            $0.font = $0.font.withSize(20)
            vfl.addView(name: "title", view: $0)
        }
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabelAttributes(titleLabel)
        } else {
            let titleLabel = UILabel()
            titleLabel.tag = 100
            titleLabelAttributes(titleLabel)
        }
        
        //Add Score
        let scoreLabelAttributes: (UILabel) -> () = {
            $0.text = story["score"].int?.description
            $0.numberOfLines = 1
            $0.font = $0.font.withSize(10)
            vfl.addView(name: "score", view: $0)
        }
        if let scoreLabel = cell.viewWithTag(101) as? UILabel {
            scoreLabelAttributes(scoreLabel)
        } else {
            let scoreLabel = UILabel()
            scoreLabel.tag = 101
            scoreLabelAttributes(scoreLabel)
        }
        
        //Add Author
        let authorLabelAttributes: (UILabel) -> () = {
            $0.text = story["by"].string
            $0.numberOfLines = 1
            $0.font = $0.font.withSize(10)
            vfl.addView(name: "author", view: $0)
        }
        if let authorLabel = cell.viewWithTag(102) as? UILabel {
            authorLabelAttributes(authorLabel)
        } else {
            let authorLabel = UILabel()
            authorLabel.tag = 102
            authorLabelAttributes(authorLabel)
        }
        
        vfl.addVFL(items: ["H:|-[score]-(>=1)-[author]-|",
                           "H:|-[title]-|",
                           "V:|-[title]-(>=1)-[score]-|",
                           "V:|-[title]-(>=1)-[author]-|"])
        
        return cell
    }
    
    @objc private func fetchData(){
        let ext = "topstories.json"
        
        let getStory: (JSON) -> Void = { jsn in
            guard let arr = jsn.array else {
                return
            }
            self.totalCount = arr.count
            for story in arr {
//                print(story.int!)
                self.api.get(ext: "item/\(story.int!).json", completion:{ (res) in
                    switch res {
                    case .completion(result: let storyJson):
                        self.stories.updateValue(storyJson, forKey: storyJson["id"].int!)
//                        self.json[storyJson["id"].string!]["story"] = storyJson
                        self.count += 1
                    default:
                        return
                    }
                    if story == arr[10] {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
        
        api.get(ext: ext, completion: { (res) in
            switch res {
            case .completion(result: let json):
                self.json = json
                getStory(json)
            case .error(message: let mes):
                DispatchQueue.main.async {
                    self.simpleErrorAlert(msg: mes)
                }
            }
        })
        
    }


}

extension UIViewController {
    func simpleErrorAlert(msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UITableView {
    func reloadDataSmoothly() {
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()
        
        CATransaction.setCompletionBlock { () -> Void in
            UIView.setAnimationsEnabled(true)
        }
        
        reloadData()
        beginUpdates()
        endUpdates()
        
        CATransaction.commit()
    }
}
