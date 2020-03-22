//
//  UIViewController+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    static func loadFromStoryboard<Controller: UIViewController>(_ name: String = "Main") -> Controller? {
        let identifier = String(describing: Controller.self)
        let viewController = UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
        return viewController as? Controller
    }
    
    func embeddInSuperController(_ superController: UIViewController, holderView: UIView, edges: UIEdgeInsets = .zero) {
        guard holderView.isDescendant(of: superController.view) else {
            LogManager.shared().log("Error: \(holderView.nameOfClass) must be a subview of \(superController.view.nameOfClass)",
                level: .debug,
                origin: self.classForCoder)
            return
        }
        superController.addChild(self)
        holderView.addSubview(view.autolayoutView())
        view.pinToTheEdgesNamed(destinationView: holderView, name: "embeddedVC", edges: edges)
        self.didMove(toParent: superController)
    }
    

    
    
}
