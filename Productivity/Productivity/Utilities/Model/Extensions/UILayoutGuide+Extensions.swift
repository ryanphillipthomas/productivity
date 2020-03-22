//
//  UILayoutGuide+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

public extension UILayoutGuide {
    
    // MARK: Edges
    func pinToTheEdges(margins: UILayoutGuide, edges: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: margins.topAnchor, constant: edges.top),
            bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -edges.bottom),
            leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: edges.left),
            trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -edges.right)
            ])
    }
    
    enum Edge: String, CaseIterable {
        case leading
        case top
        case bottom
        case trailing
        
        var offsetMultiplier: CGFloat {
            switch self {
            case .leading:
                return 1.0
            case .top:
                return 1.0
            case .trailing:
                return -1.0
            case .bottom:
                return -1.0
            }
        }
        
        func offset(for insets: UIEdgeInsets) -> CGFloat {
            switch self {
            case .leading:
                return insets.left
            case .top:
                return insets.top
            case .trailing:
                return insets.right
            case .bottom:
                return insets.bottom
            }
        }
        
        // MARK: Constraint
        func layoutConstraint(sourceLayoutGuide: UILayoutGuide, destinationLayoutGuide: UILayoutGuide, name: String, offset: CGFloat) -> NSLayoutConstraint {
            var edgeLG: NSLayoutConstraint
            let constant = offset * self.offsetMultiplier
            switch self {
            case .leading:
                edgeLG = sourceLayoutGuide.leadingAnchor.constraint(equalTo: destinationLayoutGuide.leadingAnchor, constant: constant)
            case .top:
                edgeLG = sourceLayoutGuide.topAnchor.constraint(equalTo: destinationLayoutGuide.topAnchor, constant: constant)
            case .trailing:
                edgeLG = sourceLayoutGuide.trailingAnchor.constraint(equalTo: destinationLayoutGuide.trailingAnchor, constant: constant)
            case .bottom:
                edgeLG = sourceLayoutGuide.bottomAnchor.constraint(equalTo: destinationLayoutGuide.bottomAnchor, constant: constant)
            }
            edgeLG.identifier = "\(name)_\(self.rawValue)"
            return edgeLG
        }
        
        func layoutConstraint(sourceView: UIView, destinationView: UIView, name: String, offset: CGFloat) -> NSLayoutConstraint {
            var edgeLG: NSLayoutConstraint
            let constant = offset * self.offsetMultiplier
            switch self {
            case .leading:
                edgeLG = sourceView.leadingAnchor.constraint(equalTo: destinationView.leadingAnchor, constant: constant)
            case .top:
                edgeLG = sourceView.topAnchor.constraint(equalTo: destinationView.topAnchor, constant: constant)
            case .trailing:
                edgeLG = sourceView.trailingAnchor.constraint(equalTo: destinationView.trailingAnchor, constant: constant)
            case .bottom:
                edgeLG = sourceView.bottomAnchor.constraint(equalTo: destinationView.bottomAnchor, constant: constant)
            }
            edgeLG.identifier = "\(name)_\(self.rawValue)"
            return edgeLG
        }
    }
    
    // MARK: Pin
    func pinToTheEdgeNamed(layoutGuide: UILayoutGuide, name: String, edge: Edge, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        let edgeLG = edge.layoutConstraint(sourceLayoutGuide: self, destinationLayoutGuide: layoutGuide, name: name, offset: constant)
        edgeLG.isActive = true
        return edgeLG
    }
    
    func pinToTheEdgesNamed(layoutGuide: UILayoutGuide, name: String, edges: UIEdgeInsets = .zero) {
        for edge in Edge.allCases {
            let offset = edge.offset(for: edges)
            _ = pinToTheEdgeNamed(layoutGuide: layoutGuide, name: name, edge: edge, constant: offset)
        }
    }
    
    func pinToTheEdgesNamed(layoutGuide: UILayoutGuide, name: String, edges: [UILayoutGuide.Edge], offsets: UIEdgeInsets = .zero) {
        for aEdge in edges {
            let offset = aEdge.offset(for: offsets)
            _ = pinToTheEdgeNamed(layoutGuide: layoutGuide, name: name, edge: aEdge, constant: offset)
        }
    }
}
