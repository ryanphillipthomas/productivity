//
//  IconImageSingleLabelDisclosureView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

final class IconImageSingleLabelDisclosureView: PRXibView {
    @IBOutlet weak var innerView: PRBaseView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: PRFadeImageView!
    @IBOutlet weak var disclourseImageView: UIImageView!

    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Styles
    private func setStyles() {
        innerView.roundCorners()
    }
}
