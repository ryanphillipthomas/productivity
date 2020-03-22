//
//  PRTableViewHeaderFooterView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class PRTableViewHeaderFooterView<View: UIView>: UITableViewHeaderFooterView {

    var cellView: View? {
        didSet {
            guard cellView != nil else { return }
            configureViews()
        }
    }
    
    //MARK: Initialization
    public required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    //MARK: Reuse
    override public func prepareForReuse() {
        if let aSubview = self.cellView as? PRBaseView {
            aSubview.cleanViews()
        }
        super.prepareForReuse()
    }
    
    // MARK: Private
    private func configureViews() {
        guard let cellView = cellView else { return }
        self.accessibilityLabel = "TVHF_\(self.nameOfClass)"
        addSubview(cellView)
        cellView.pinToTheEdgesNamed(destinationView: self, name: "headerFooter")
        // or
        //    cellView.safeAreaLayoutGuide.pinToTheEdgesNamed(layoutGuide: self.safeAreaLayoutGuide, name: "headerFooter")
    }
    
    // MARK: Public
    public func customize(any: Any) {
        if let aSubview = self.cellView as? PRBaseView {
            aSubview.customize(any: any)
        }
    }
}

