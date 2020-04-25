//
//  ColorsCollectionViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 4/12/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

protocol ColorsCollectionViewControllerDelegate: NSObjectProtocol {
    func didSelectColor(colorValue: String)
}

class ColorsCollectionViewController: UICollectionViewController {
    weak var delegate: ColorsCollectionViewControllerDelegate?

    var colors:[String]?
    
    func color(index: Int) -> UIColor? {
        if let colors = colors {
            return UIColor(hexString: colors[index])
        }
        return UIColor.red
    }
    
    fileprivate func configureColors() {
        if let path = Bundle.main.path(forResource: "colors", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<String> {
                    colors = jsonResult
                }
            } catch {
                print("Error parsing json")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureColors()
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


       override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let colors = colors {
            return colors.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorCollectionViewCell.classForCoder()), for: indexPath) as! ColorCollectionViewCell
        cell.configureColor(color: color(index: indexPath.row))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            if let colors = colors {
                delegate.didSelectColor(colorValue: colors[indexPath.row])
            }
            navigationController?.popViewController(animated: true)
        }
    }
}
