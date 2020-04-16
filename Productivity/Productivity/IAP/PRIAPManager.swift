//
//  PRIAPManager.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import StoreKit

public typealias ProductID = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias ProductPurchaseCompletionHandler = (_ success: Bool, _ productId: ProductID?) -> Void

// MARK: - PRIAPManager
public class PRIAPManager: NSObject  {
  private let productIDs: Set<ProductID>
  private var purchasedProductIDs: Set<ProductID>
  private var productsRequest: SKProductsRequest?
  private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
  private var productPurchaseCompletionHandler: ProductPurchaseCompletionHandler?
  
  public init(productIDs: Set<ProductID>) {
    self.productIDs = productIDs
    self.purchasedProductIDs = productIDs.filter { productID in
      let purchased = UserDefaults.standard.bool(forKey: productID)
      if purchased {
        print("Previously purchased: \(productID)")
      } else {
        print("Not purchased: \(productID)")
      }
      return purchased
    }
    super.init()
    SKPaymentQueue.default().add(self)
  }
}

// MARK: - StoreKit API
extension PRIAPManager {
  public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler

    productsRequest = SKProductsRequest(productIdentifiers: productIDs)
    productsRequest!.delegate = self
    productsRequest!.start()
  }

  public func buyProduct(_ product: SKProduct, _ completionHandler: @escaping ProductPurchaseCompletionHandler) {
    productPurchaseCompletionHandler = completionHandler
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  public func isProductPurchased(_ productID: ProductID) -> Bool {
    return purchasedProductIDs.contains(productID)
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  public func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

// MARK: - SKProductsRequestDelegate
extension PRIAPManager: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    print("Loaded list of products...")
    let products = response.products
    guard !products.isEmpty else {
      print("Product list is empty...!")
      print("Did you configure the project and set up the IAP?")
      productsRequestCompletionHandler?(false, nil)
      return
    }
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()
    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
  }

  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Failed to load list of products.")
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }

  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver
extension PRIAPManager: SKPaymentTransactionObserver {
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }

  private func complete(transaction: SKPaymentTransaction) {
    print("complete...")
    productPurchaseCompleted(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
    print("restore... \(productIdentifier)")
    productPurchaseCompleted(identifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func fail(transaction: SKPaymentTransaction) {
    print("fail...")
    if let transactionError = transaction.error as NSError?,
      let localizedDescription = transaction.error?.localizedDescription,
        transactionError.code != SKError.paymentCancelled.rawValue {
        print("Transaction Error: \(localizedDescription)")
      }

    productPurchaseCompletionHandler?(false, nil)
    SKPaymentQueue.default().finishTransaction(transaction)
    clearHandler()
  }

  private func productPurchaseCompleted(identifier: ProductID?) {
    guard let identifier = identifier else { return }

    purchasedProductIDs.insert(identifier)
    UserDefaults.standard.set(true, forKey: identifier)
    productPurchaseCompletionHandler?(true, identifier)
    clearHandler()
  }

  private func clearHandler() {
    productPurchaseCompletionHandler = nil
  }
}
