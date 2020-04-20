//
//  WUTableViewCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

open class PRBaseTableViewCell<View: UIView>: UITableViewCell {
    
    var cellView: View? {
        didSet {
            guard cellView != nil else { return }
            configureViews()
        }
    }

    //MARK: Initialization
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.configureAccessibilityIdentifiers()
        setStyles()
    }
    
    //MARK: Styles
    private func setStyles() {
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    //MARK: Reuse
    override open func prepareForReuse() {
        if let aSubview = self.cellView as? PRBaseView {
            aSubview.cleanViews()
        }
        super.prepareForReuse()
    }
    
    //MARK: Selection
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Private
    private func configureViews() {
        guard let cellView = cellView else { return }
        self.accessibilityLabel = "BTVC_\(self.nameOfClass)"
        addSubview(cellView)
        cellView.pinToTheEdgesNamed(destinationView: self, name: "cellView")
        // or
        //    cellView.safeAreaLayoutGuide.pinToTheEdgesNamed(layoutGuide: self.safeAreaLayoutGuide, name: "cellView")
    }
    
    //MARK: Public
    public func customize(any: Any) {
        if let aSubview = self.cellView as? PRBaseView {
            aSubview.customize(any: any)
        }
    }
}
