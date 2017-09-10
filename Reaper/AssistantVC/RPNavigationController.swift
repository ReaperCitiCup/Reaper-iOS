//
//  RPNavigationController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    var navigationBarBottomLine: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationBarBottomLine = findBottomLine(under: self.navigationBar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarBottomLine?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationBarBottomLine?.isHidden = false
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count >= 1 {
            let button = UIButton(type: .custom)
            button.bounds = CGRect(x: 0, y: 0, width: 100, height: 21)
            button.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
            button.setImage(#imageLiteral(resourceName: "nav_back"), for: .highlighted)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets.zero
            button.addTarget(self, action: #selector(back), for: .touchUpInside)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc func back() {
        self.popViewController(animated: true)
    }
    
    private func findBottomLine(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            let imageView = self.findBottomLine(under: subview)
            if imageView != nil {
                return imageView
            }
        }
        return nil
    }

}
