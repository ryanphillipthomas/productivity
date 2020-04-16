//
//  PRIAPManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import Foundation

public struct PRProducts {
  public static let monthlySub = "com.ryanphillipthomas.checkit.one.month.premium"
  public static let yearlySub = "com.ryanphillipthomas.checkit.one.year.premium"
  public static let store = PRIAPManager(productIDs: PRProducts.productIDs)
    private static let productIDs: Set<ProductID> = [PRProducts.monthlySub, PRProducts.yearlySub]
}

public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
