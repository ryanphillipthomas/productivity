//
//  PRSubscriptionViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/15/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit
import StoreKit

public struct QuotesGroup: Decodable {
  public let quotes: [String]
}

class PRSubscriptionViewController: PRBaseViewController {
    var quotesContent: QuotesGroup!
    var products: [SKProduct] = []
    
    @IBOutlet var quoteLbl: UILabel!
    @IBOutlet var purchaseBttn: UIButton!
    @IBOutlet var restoreBttn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadQuotesFromFile()
        PRProducts.store.requestProducts { [weak self] success, products in
          guard let self = self else { return }
          guard success else {
            let alertController = UIAlertController(title: "Failed to load list of products",
                                                    message: "Check logs for details",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
          }
          self.products = products!
        }
        if PRProducts.store.isProductPurchased(PRProducts.monthlySub) || PRProducts.store.isProductPurchased(PRProducts.yearlySub){
          displayRandomQuote()
        } else {
          displayPurchaseQuotes()
        }
    }

    func loadQuotesFromFile() {
      guard let filePath = Bundle.main.path(forResource: "poohWisdom", ofType: "json") else {
        fatalError("Quotes file path is incorrect!")
      }
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        quotesContent = try JSONDecoder().decode(QuotesGroup.self, from: data)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
    
    // MARK: - IBActions
    @IBAction func purchaseSubscription(_ sender: Any) {
      guard !products.isEmpty else {
        print("Cannot purchase subscription because products is empty!")
        return
      }
      PRProducts.store.buyProduct(products[0]) { [weak self] success, productId in
        guard let self = self else { return }
        guard success else {
          let alertController = UIAlertController(title: "Failed to purchase product",
                                                  message: "Check logs for details",
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alertController, animated: true, completion: nil)
          return
        }
        self.displayRandomQuote()
      }
    }

    @IBAction func restorePurchases(_ sender: Any) {
      PRProducts.store.restorePurchases()
    }

    // MARK: - Displaying Quotes
    private func displayPurchaseQuotes() {
      quoteLbl.text = "Wanna get random words of wisdom from Winnie the Pooh?\n\n" +
                      "Press the 'Purchase' button!\nWhat are you waiting for?!"
    }
    
    private func displayRandomQuote() {
      let randNum = Int.random(in: 0 ..< quotesContent.quotes.count)
      quoteLbl.text = quotesContent.quotes[randNum]
      purchaseBttn.isHidden = true
      restoreBttn.isHidden = true
    }
}
