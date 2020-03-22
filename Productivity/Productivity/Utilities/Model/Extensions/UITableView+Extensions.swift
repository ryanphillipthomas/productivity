//
//  UITableView+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
    
    //MARK: Register
    func registerCell<Cell: UITableViewCell>(_ cellClass: Cell.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    //MARK: Cell
    func dequeueReusableCell<Cell: UITableViewCell>(forIndexPath indexPath: IndexPath) -> Cell {
        
        let identifier = String(describing: Cell.self)
        
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
            let errStr = "Error for cell id: \(identifier) at \(indexPath))"
            fatalError(errStr)
        }
        return cell
    }
    
    //MARK: HeaderFooter
    func registerHeaderFooter<HeaderFooter: UITableViewHeaderFooterView>(_ headerFooterClass: HeaderFooter.Type) {
        register(headerFooterClass, forHeaderFooterViewReuseIdentifier: String(describing: headerFooterClass))
    }
    
    func dequeueReusableHeaderFooter<HeaderFooter: UITableViewHeaderFooterView>(with identifier: String? = nil) -> HeaderFooter {
        
        let ident = identifier ?? String(describing: HeaderFooter.self)
        
        guard let headerFooter = self.dequeueReusableHeaderFooterView(withIdentifier: ident) as? HeaderFooter else {
            let errStr = "Error for headerFooter id: \(ident) at \(String(describing: indexPath)))"
            fatalError(errStr)
        }
        return headerFooter
    }
    
    //MARK: TableHeader
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableHeaderView = header
    }
    
    func setAndLayoutTableFooterView(header: UIView) {
        self.tableFooterView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableFooterView = header
    }
}
