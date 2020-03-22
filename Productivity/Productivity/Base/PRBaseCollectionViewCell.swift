//
//  WUCollectionViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

open class PRBaseCollectionViewCell<View: UIView>: UICollectionViewCell {
    
    var cellView: View? {
        didSet {
            guard cellView != nil else { return }
            configureViews()
        }
    }

    //MARK: Initialization
    override open func awakeFromNib() {
        super.awakeFromNib()
        contentView.configureAccessibilityIdentifiers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Reuse
    override open func prepareForReuse() {
        if let aSubview = self.cellView as? PRBaseView {
            aSubview.cleanViews()
        }
        super.prepareForReuse()
    }
    
    //MARK: Private
    private func configureViews() {
        guard let cellView = cellView else { return }
        addSubview(cellView)
        cellView.pinToTheEdgesNamed(destinationView: self, name: "collectionCell")
        // or
        //    cellView.safeAreaLayoutGuide.pinToTheEdgesNamed(layoutGuide: self.safeAreaLayoutGuide, name: "collectionCell")
    }
    
    //MARK: Public
    public func customize(any: Any) {
        if let aSubview = self.cellView as? PRBaseView {
            aSubview.customize(any: any)
        }
    }
}
