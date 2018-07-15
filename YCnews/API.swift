//
//  API.swift
//  YCnews
//
//  Created by Jack Weber on 7/2/18.
//  Copyright © 2018 Jack Weber. All rights reserved.
//

import UIKit

enum result {
    case error(message: String)
    case completion(result: JSON)
}

class Comment {
    var data: JSON!
    var children: [Comment] = [Comment]()
    private func mCount(_ comment: Comment) -> Int {
        var ret = 0
        for child in children {
            ret += mCount(child)
        }
        return ret
    }
    func getCount() -> Int {
        return 1 + mCount(self)
    }
}

class API: NSObject {
    
    private var baseUrlString: String!
    
    
    init(urlString: String) {
        baseUrlString = urlString
    }
    
    func get(ext: String, completion: @escaping (result) -> Void ){
        guard let url = URL(string: baseUrlString + ext) else {
            return
        }
        getJSONRequest(url: url, completion: completion)
        return
    }
    
    private func getJSONRequest(url: URL, completion: @escaping (result) -> Void ){
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) { (data, res, err) in
            guard let response = res as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                completion(result.error(message: "Could not retrieve data"))
                return
            }
            if let dat = data, let dataString = String(data: dat, encoding: .utf8) {
                completion(result.completion(result: JSON(parseJSON: dataString)))
            } else {
                completion(result.error(message: "Could not parse JSON"))
            }
        }.resume()
    }
    
    //YC Specific
    //Comment Aggregation
    
    private var rootComment = Comment()
    var commentCount = 0
    
    private func mComments(base: Comment) -> Comment {
        guard let children = base.data["kids"].arrayObject as? [Int] else {
            return base
        }
        var siblingData = [JSON]()
        var barrier = children.count
        for kid in children {
            get(ext: "item/\(kid).json") { (res) in
                switch res {
                case result.completion(result: let json):
                    siblingData.append(json)
                    self.commentCount += 1
                default:
                    break
                }
                barrier -= 1
            }
        }
        while(barrier > 0) {
            
        }
        while(siblingData != []) {
            if let item = siblingData.popLast() {
                let newComment = Comment()
                newComment.data = item
                base.children.append(mComments(base: newComment))
            }
        }
        return base
        
    }
    
    func getComments(post: JSON) -> Comment {
        rootComment.data = post
        return mComments(base: rootComment)
    }
    
}
