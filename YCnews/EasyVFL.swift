//
//  EasyVFL.swift
//  YCnews
//
//  Created by Jack Weber on 7/9/18.
//  Copyright © 2018 Jack Weber. All rights reserved.
//

import UIKit

class EasyVFL: NSObject {
    
    private var parentView: UIView!
    private var viewMap = [String: Any]()
    private var constraints = [String]()
    
    init(parentView: UIView) {
        self.parentView = parentView
    }
    
    func addView(name: String, view: UIView){
        viewMap.updateValue(view, forKey: name)
        addSubViews()
    }
    
    func addViews(_ items: [String: Any]) {
        for item in items.keys{
            if let view = items[item] {
                viewMap.updateValue(view, forKey: item)
            }
        }
        addSubViews()
    }
    
    func addVFL(item: String){
        constraints.append(item)
        addConstraints()
    }
    
    func addVFL(items: [String]){
        for item in items{
            constraints.append(item)
        }
        addConstraints()
    }
    
    private func addSubViews(){
        for name in viewMap.keys  {
            if let view = viewMap[name] as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = false
                parentView.addSubview(view)
            }
        }
    }
    
    private func addConstraints(){
        if let constraint = constraints.popLast(){
            parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraint, options: [], metrics: nil, views: viewMap))
            addConstraints()
        }
    }

}
