//
//  NSObject+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

public extension NSObject {
    
  class var nameOfClass: String {
    return String(describing: self)
  }
  
  var nameOfClass: String {
    return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? "unknown_class"
  }
    
    #warning("move this")
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
