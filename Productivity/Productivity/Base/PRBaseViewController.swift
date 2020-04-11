//
//  PRBaseViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import CoreData

protocol KeyboardDelegate: NSObjectProtocol {
    func keyboardDidShow(keyboardFrame: CGRect)
    func keyboardDidHide()
}

open class PRBaseViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext!
    var wuLoading: PRLoadingAnimation?
    var tapAwayGestureRecognizer: UITapGestureRecognizer?
    
    weak var keyboardDelegate: KeyboardDelegate?
    
    @IBOutlet var screenLabel: UILabel!

    //MARK: View Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.configureAccessibilityIdentifiers()
        configureObservers()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLoader()                    //If we are leaving a view, we should never have a loader still active
        removeTapGestureRecognizer()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: Observers
    func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    //MARK: Gesture Recognizers
    func configureUITextFieldTapAwayGestureRecognizer(view: UIView) {
        tapAwayGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapAway))
        if let tap = tapAwayGestureRecognizer {
            tap.numberOfTapsRequired = 1
            view.addGestureRecognizer(tap)
        }
    }
    
    func removeTapGestureRecognizer() {
        if let tap = tapAwayGestureRecognizer {
            view.removeGestureRecognizer(tap)
            tapAwayGestureRecognizer = nil
        }
    }
    
    @objc func handleTapAway() {
        let textFields: [UITextField] = view.subviewsRecursive().filter {$0 is UITextField } as! [UITextField]
        for textField in textFields {
            textField.resignFirstResponder()
        }
    }
    
    //MARK: Status Bar
    func configureStatusBarStyle(style: UIStatusBarStyle) {
        UIApplication.shared.statusBarStyle = style
    }
    
    //MARK: Keyboard
    @objc func keyboardWillShow(notification: Notification) {
        if let delegate = keyboardDelegate {
            let userInfo = notification.userInfo!
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = view.convert(keyboardFrame, from: nil)
            delegate.keyboardDidShow(keyboardFrame: keyboardFrame)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let delegate = keyboardDelegate {
            delegate.keyboardDidHide()
        }
    }
    
    func configureViewForKeyboard(activeTextField: UITextField, keyboardFrame: CGRect, scrollView: UIScrollView? = nil) {
        let activeFieldFrame = view.convert(activeTextField.frame, from: nil)
        let topOfKeyboardFrame = view.frame.maxY - keyboardFrame.height
        let bottomOfActiveField = activeFieldFrame.maxY
        
        if let scrollView = scrollView {
            var contentInset: UIEdgeInsets = scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height - 20
            scrollView.contentInset = contentInset
        } else {
            if bottomOfActiveField > topOfKeyboardFrame {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2) {
                        self.view.frame = CGRect(x: 0,
                                                 y: -((bottomOfActiveField - topOfKeyboardFrame) + 20),
                                                 width: self.view.frame.width,
                                                 height: self.view.frame.height)
                    }
                }
            }
        }
    }
    
    func configureViewForHiddenKeyboard(scrollView: UIScrollView? = nil) {
        if let scrollView = scrollView {
            scrollView.contentInset = .zero
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: self.view.frame.width,
                                             height: self.view.frame.height)
                }
            }
        }
    }
    
    //MARK: Loader Animation
    func startLoader() {
        
        //Setup Loader
        wuLoading = PRLoadingAnimation()
        UIApplication.shared.keyWindow?.addSubview(wuLoading!)
        wuLoading?.centerMe()
        
        if let loader = wuLoading {
            view.isUserInteractionEnabled = false
            DispatchQueue.main.async {
                loader.fadeIn()
            }
        }
    }
    
    func stopLoader() {
        if let loader = wuLoading {
            view.isUserInteractionEnabled = true
            DispatchQueue.main.async {
                loader.fadeOut()
            }
        }
    }
}
