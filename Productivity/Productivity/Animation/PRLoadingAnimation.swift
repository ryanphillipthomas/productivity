//
//  PRLoadingAnimation.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import Lottie

fileprivate enum LoaderBackground {
    case BlueTranslucent
    case BlueSolid
    case Transparent
    case WhiteSolid
}

fileprivate enum TailColor {
    case BlueTail
    case PinkTail
}

let animationName: String = "wuLoadingAnimation"

class PRLoadingAnimation: UIView {
    
    var timer: Timer?
    var loaderCaption: UILabel?
    var animation: AnimationView?
    var loaderBackground: UIView?
    
    var isLooping: Bool {
        return animation?.loopMode == LottieLoopMode.loop
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    //MARK: Private
    private func initialize() {
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
        configureObservers()
        configureLoaderBackground()
        configureAnimation()
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(fadeOut), name: Constants.Notifications.nInternetAccessUnavailable, object: nil)
    }
    
    private func configureLoaderBackground() {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        loaderBackground = UIView(frame: CGRect(x: -screenWidth/2, y: -screenHeight/2, width: screenWidth, height: screenHeight))
        setLoaderBackgroundColor(loaderBackgroundColor: .BlueTranslucent)
        if let loaderBackground = loaderBackground {
            addSubview(loaderBackground)
        }
    }
    
    private func configureAnimation() {
        animation = AnimationView(name: animationName)
        animation?.loopMode = LottieLoopMode.loop
        animation?.animationSpeed = 1.0
        animation?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animation?.center = CGPoint.zero
        animation?.contentMode = .scaleAspectFit
        animation?.backgroundColor = .clear
        if let animation = animation {
            addSubview(animation)
        }
        
        backgroundColor = .clear
        alpha = 0
        translatesAutoresizingMaskIntoConstraints = false
        setTailColor(tailColor: .BlueTail)
    }
    
    private func setLoaderBackgroundColor(loaderBackgroundColor: LoaderBackground) {
        switch(loaderBackgroundColor) {
        case .WhiteSolid:           loaderBackground?.backgroundColor = UIColor.white
        case .BlueTranslucent:      loaderBackground?.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        case .BlueSolid:            loaderBackground?.backgroundColor = UIColor.blue.withAlphaComponent(1.0)
        case .Transparent:          loaderBackground?.backgroundColor = UIColor.clear
        }
    }
    
    private func setTailColor(tailColor: TailColor) {
        var color: UIColor!
        switch(tailColor) {
        case .BlueTail:     color = UIColor.blue
        case .PinkTail:     color = UIColor.purple
        }
        
        let colorProvider = ColorValueProvider(Color(r: Double(color.redValue), g: Double(color.greenValue), b: Double(color.blueValue), a: Double(color.alphaValue)))
        animation?.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "WU_TailLogo3.Tail.Group 3.Fill 1.Color"))   //Tail #1
        animation?.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "WU_TailLogo3.Tail 2.Group 3.Fill 1.Color"))   //Tail #2
    }
    
    //MARK: Public
    func centerIn(view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func centerMe() {
        if let window = UIApplication.shared.delegate?.window {
            if let xAnchor = window?.centerXAnchor {
                centerXAnchor.constraint(equalTo: xAnchor).isActive = true
            }
            if let yAnchor = window?.centerYAnchor {
                centerYAnchor.constraint(equalTo: yAnchor).isActive = true
            }
        }
    }
    
    @objc func fadeIn() {
        timer = Timer.scheduledTimer(timeInterval: Constants.networkTimeout, target: self, selector: #selector(fadeOut), userInfo: nil, repeats: false) //Failsafe
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
            self.animation?.play()
        }
    }
    
    @objc func fadeOut() {
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.animation?.alpha = 0.0
                        self.alpha = 0.0
                        //loader caption
        }) { (finished) in
            self.animation?.stop()
            
            // We're adding loaders to the application window
            // don't let the loaders accumulate and stay in memory.  remove them from the app window
            if let window = UIApplication.shared.keyWindow {
                for subview in window.subviews {
                    if (subview.isKind(of: self.classForCoder)) {
                        subview.removeFromSuperview()
                        //loader caption remove
                    }
                }
            }
        }
    }
    
    func addCaption(text: String) {
        #warning("Migrate addCaption logic from original repo")
    }

}
