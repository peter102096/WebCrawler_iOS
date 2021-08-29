//
//  Extensions.swift
//  WebCrawler_iOS
//
//  Created by Peter on 2021/8/29.
//

import Foundation
import UIKit

extension UIViewController {
    
    fileprivate class func fromStoryBoardHelper<T>(storyBoardName: String, storyBoardID: String) -> T
    {
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: storyBoardID) as! T
        return controller
    }
    
    func name() -> String {
        return String(describing: self)
    }
    
    static func fromStoryBoard() -> Self {
        let id = String(describing: self)
        return fromStoryBoardHelper(storyBoardName: "Main", storyBoardID: id)
    }
    
    func push(vc:UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pop(toRoot: Bool) {
        if toRoot {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func popTo(_ vc: UIViewController) {
        self.navigationController?.popToViewController(vc, animated: true)
    }
}

