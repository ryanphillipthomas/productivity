//
//  PRBaseNavigationController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

protocol PRBaseNavigationControllerDelegate: NSObjectProtocol {
    func didPressLeftBarButtonItem()
    func didPressRightBarButtonItem()
}

class PRBaseNavigationController: UINavigationController {
    
    weak var wuDelegate: PRBaseNavigationControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: Style
    private func setStyle() {
        navigationBar.barStyle = .default
        navigationBar.isTranslucent = true
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    //MARK: Public
    public func configureNavBar(title: String,
                                subtitle: String? = nil,
                                leftImage: UIImage? = nil,
                                rightImage: UIImage? = nil,
                                letfButtonText: String? = nil,
                                rightButtonText: String? = nil,
                                buttonColorOverride: UIColor? = nil) {

        if let currentNavigationItem = viewControllers.last?.navigationItem {
            
            if let leftImage = leftImage {
                let leftButton = UIButton(type: .custom)
                leftButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                leftButton.setImage(leftImage, for: .normal)
                leftButton.imageView?.contentMode = .scaleAspectFill
                leftButton.addTarget(self, action: #selector(didPressLeftBarButtonItem), for: .touchUpInside)
                currentNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
            }
            
            if let letfButtonText = letfButtonText {
                let leftButton = UIButton(type: .custom)
                leftButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                leftButton.setTitle(letfButtonText, for: .normal)
                if let buttonColorOverride = buttonColorOverride {
                    leftButton.setTitleColor(buttonColorOverride, for: .normal)
                }
                leftButton.addTarget(self, action: #selector(didPressLeftBarButtonItem), for: .touchUpInside)
                currentNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
            }
            
            if let rightImage = rightImage {
                let rightButton = UIButton(type: .custom)
                rightButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                rightButton.setImage(rightImage, for: .normal)
                rightButton.imageView?.contentMode = .scaleAspectFill
                rightButton.addTarget(self, action: #selector(didPressRightBarButtonItem), for: .touchUpInside)
                currentNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
            }
            
            if let rightButtonText = rightButtonText {
                let rightButton = UIButton(type: .custom)
                rightButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                rightButton.setTitle(rightButtonText, for: .normal)
                if let buttonColorOverride = buttonColorOverride {
                    rightButton.setTitleColor(buttonColorOverride, for: .normal)
                }
                rightButton.addTarget(self, action: #selector(didPressRightBarButtonItem), for: .touchUpInside)
                currentNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
            }
            
            if let subtitle = subtitle {
                let titleLabel = UILabel()
                titleLabel.numberOfLines = 0
                titleLabel.textAlignment = .center
                let titleAttributedString = NSMutableAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                                                         NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
                titleAttributedString.append(NSMutableAttributedString(string: subtitle, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                                                      NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
                titleLabel.attributedText = titleAttributedString
                currentNavigationItem.titleView = titleLabel
                
            } else {
                currentNavigationItem.title = title
            }
        }
    }
    
    @objc func didPressLeftBarButtonItem() {
        if let delegate = wuDelegate {
            delegate.didPressLeftBarButtonItem()
        }
    }
    
    @objc func didPressRightBarButtonItem() {
        if let delegate =  wuDelegate {
            delegate.didPressRightBarButtonItem()
        }
    }
}
