//
//  Data+Extensions.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

public extension Data {
    
    func responseDataString() -> String {
        var resultString = String()
        if self.count > 0 {
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: self, options: []) as? [[String: Any]] {
                    resultString = String(describing:jsonResult)
                } else if let jsonResults = try JSONSerialization.jsonObject(with: self, options: []) as? [String:Any] {
                    resultString = jsonResults.prettyPrintedJSON ?? ""
                } else {
                    print("Could not parse data")
                }
            } catch let error {
                #if DEBUG
                print(error)
                #endif
            }
        }
        return resultString
    }
    
}
