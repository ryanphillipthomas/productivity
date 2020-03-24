//
//  IconView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/23/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class IconView: PRXibView {
    @IBOutlet weak var imageView: UIImageView!

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
        
    }
}
