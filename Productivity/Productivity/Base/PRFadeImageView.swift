//
//  PRFadeImageView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import SDWebImage
import SkeletonView

class PRFadeImageView: UIImageView {

    typealias CompletionHandler = (_ success: Bool) -> Void
    var fadeDuration: Double = 0.3
    var fadeDurationFromCache: Double = 0.05
    
    override var image: UIImage?
        {
        get {
            return super.image
        }
        set(newImage)
        {
            if let img = newImage
            {
                CATransaction.begin()
                CATransaction.setAnimationDuration(self.fadeDuration)
                
                let transition = CATransition()
                transition.type = CATransitionType.fade
                
                super.layer.add(transition, forKey: kCATransition)
                super.image = img
                
                CATransaction.commit()
            }
            else {
                super.image = nil
            }
        }
    }
    
    func loadImageFromImagePath(imagePath: String?,
                                disableImageViewSkeleton: Bool = false,
                                viewsToAnimate: [UIView] = [],
                                viewsToSkeletonize: [UIView] = [],
                                placeholderImage: UIImage? = UIImage(named: ""),
                                errorStateImage: UIImage? = UIImage(named: "broken_image"),
                                completionBlock: CompletionHandler?) {
        
        //Check if the imageURL is the same one as param imagePath.  If yes, then no need to reload image
        let encodedImagePath = imagePath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard self.sd_imageURL()?.absoluteString != encodedImagePath else {
            if let completion = completionBlock { completion(false) }
            return
        }
        //If we have already have an image and imagePath is nil, then don't reload since its just showing a placeholder image and those are unlikely to change
        if (imagePath == nil && self.image != nil) {
            if let completion = completionBlock { completion(false) }
            return
        }
        
        
        if (!disableImageViewSkeleton) {
            self.isSkeletonable = true
            self.showAnimatedGradientSkeleton()
        }
        
        self.removeBrokenImage()
        for view in viewsToAnimate { view.alpha = 0.0 }
        for view in viewsToSkeletonize {
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton()
        }
        
        self.sd_setImage(with: URL(string: encodedImagePath),
                         placeholderImage: placeholderImage,
                         options: SDWebImageOptions.avoidAutoSetImage) { (image, error, cacheType, url) in
                            guard let image = image else {
                                DispatchQueue.main.async {
                                    if (!disableImageViewSkeleton) { self.hideSkeleton() }
                                    if let brokenImage = errorStateImage { self.addBrokenImage(brokenImage: brokenImage) }
                                    UIView.animate(withDuration: (cacheType == SDImageCacheType.memory) ? self.fadeDurationFromCache : self.fadeDuration,
                                                   animations: {
                                                    for view in viewsToAnimate { view.alpha = 1.0 }
                                                    //self.backgroundColor = UIColor.mediumGrayColor
                                    }, completion: { (success) in
                                        for view in viewsToSkeletonize { view.hideSkeleton() }
                                        if let completion = completionBlock { completion(true) }
                                    })
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.image = image
                                UIView.animate(withDuration: (cacheType == SDImageCacheType.memory) ? self.fadeDurationFromCache : self.fadeDuration,
                                               animations: {
                                                for view in viewsToAnimate { view.alpha = 1.0 }
                                }, completion: { (success) in
                                    for view in viewsToSkeletonize { view.hideSkeleton() }
                                    if (!disableImageViewSkeleton) { self.hideSkeleton() }
                                    if let completion = completionBlock {
                                        completion(true)
                                    }
                                })
                            }
        }
    }
    
    func addBrokenImage(brokenImage: UIImage) {
        removeBrokenImage()
        let brokenImageView = UIImageView(frame: CGRect(x: self.center.x - 20,
                                                        y: self.center.y - 20,
                                                        width: 40.0,
                                                        height: 40.0))
        brokenImageView.image = brokenImage
        //brokenImageView.tintColor = UIColor.bodyGreyLabelTextColor
        brokenImageView.tag = 999           // So we can easily locate the correct subviews to remove
        self.addSubview(brokenImageView)
    }
    
    /*
     Remove any subview from self with tag of 999.  Tag == 999 is reserved for the broken image imageview subview
     */
    func removeBrokenImage() {
        for subview in self.subviews {
            if (subview.tag == 999) {
                subview.removeFromSuperview()
            }
        }
    }

}
