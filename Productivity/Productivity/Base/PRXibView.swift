//
//  PRXibView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class PRXibView: PRBaseView {

    @IBOutlet var view: UIView!
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureXib()
    }
    
    private func configureXib(){
        view = loadViewFromXib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = .clear
        backgroundColor = .clear
        addSubview(view)
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let xib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let xibView = xib.instantiate(withOwner: self, options: nil).first as! UIView
        return xibView
    }
    
}
