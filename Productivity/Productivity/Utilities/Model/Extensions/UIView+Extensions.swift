//
//  UIView+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

/*
 8/20/19 - IMPORTANT
 
 The following files were NOT migrated to new codebase.  These still exist in the old codebase and can be brought over from there on an adhoc
 basis.  Should be converted to Swift if/when migrated
 
 UIView+Toast
 UIView+Screenshot
 */

extension UIView {
    
    public func roundCorners() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    //MARK: Accessibility Identifiers
    public func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
    
    public func configureAccessibilityIdentifiers() {
        var subviewDict: [String : Int] = [:]
        for subview in subviewsRecursive() {
            let subviewType = String(describing: type(of: subview).self)
            var subviewCount = subviewDict[subviewType] ?? 0
            subviewCount += 1
            subviewDict[subviewType] = subviewCount
            subview.accessibilityIdentifier = "\(subviewType)_\(subviewCount)"
            //LogManager.shared().log("\(String(describing: subview.accessibilityIdentifier))", level: .verbose, origin: self.classForCoder)
        }
    }
    
    //MARK: Auto Layout
    class func autolayoutView() -> Self {
        let view = self.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityLabel = "WU_\(self.nameOfClass)"
        return view
    }
    
    func autolayoutView() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = "WU_\(self.nameOfClass)"
        return self
    }
    
    //MARK: Pin
    public func pinToTheEdgeNamed(destinationView: UIView, name: String, edge: UILayoutGuide.Edge, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        let edgeLG = edge.layoutConstraint(sourceView: self, destinationView: destinationView, name: name, offset: constant)
        edgeLG.isActive = true
        return edgeLG
    }
    
    public func pinToTheEdgesNamed(destinationView: UIView, name: String, edges: UIEdgeInsets = .zero) {
        for edge in UILayoutGuide.Edge.allCases {
            let offset = edge.offset(for: edges)
            _ = pinToTheEdgeNamed(destinationView: destinationView, name: name, edge: edge, constant: offset)
        }
    }
    
    public func pinToTheEdgesNamed(destinationView: UIView, name: String, edges: [UILayoutGuide.Edge], offsets: UIEdgeInsets = .zero) {
        for aEdge in edges {
            let offset = aEdge.offset(for: offsets)
            _ = pinToTheEdgeNamed(destinationView: destinationView, name: name, edge: aEdge, constant: offset)
        }
    }
}
