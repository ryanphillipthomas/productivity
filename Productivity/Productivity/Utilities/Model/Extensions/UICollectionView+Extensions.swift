//
//  UICollectionView+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    // MARK: Register
    func registerCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    // MARK: Dequeue
    func dequeueReusableCell<Cell: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> Cell {
        
        let identifier = String(describing: Cell.self)
        
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            let errStr = "Error for cell id: \(identifier) at \(indexPath))"
            fatalError(errStr)
        }
        return cell
    }
    
}
