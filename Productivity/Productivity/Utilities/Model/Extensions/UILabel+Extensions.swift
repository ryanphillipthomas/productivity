//
//  UILabel+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func countLabelLines() -> Int {
        if let text = self.text {
            let attributes = [NSAttributedString.Key.font : self.font]
            let size = text.boundingRect(with: CGSize(width: self.bounds.width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
            return Int(ceil(CGFloat(size.height / self.font.lineHeight)))
        }
        return 0
    }
    
    public func isMultiline() -> Bool {
        return self.countLabelLines() > 1 ? true : false
    }
}
