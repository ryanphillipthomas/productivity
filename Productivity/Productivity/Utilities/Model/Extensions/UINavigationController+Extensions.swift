//
//  UINavigationController+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    //MARK: Navigation
    public func pushWithTransition(viewController: UIViewController, transitionType: CATransitionType = CATransitionType.fade) {
        let transition: CATransition = CATransition()
        transition.duration = 0.2
        transition.type = transitionType
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
    
    public func popWithTransition(transitionType: CATransitionType = CATransitionType.fade) {
        let transition: CATransition = CATransition()
        transition.duration = 0.2
        transition.type = transitionType
        view.layer.add(transition, forKey: nil)
        popViewController(animated: false)
    }
}
