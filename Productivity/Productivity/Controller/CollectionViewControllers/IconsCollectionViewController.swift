//
//  IconsCollectionViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/23/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

//MARK: EditRoutineTableViewControllerDelegate
protocol IconsCollectionViewControllerDelegate: NSObjectProtocol {
    func didSelectIcon(iconName: String)
}

class IconsCollectionViewController: UICollectionViewController {
    weak var delegate: IconsCollectionViewControllerDelegate?

    var icons:[String]?
    
    func icon(index: Int) -> UIImage? {
        if let icons = icons {
            return UIImage(systemName: icons[index])
        }
        return UIImage(systemName: "wifi")
    }

    fileprivate func configureIcons() {
        if let path = Bundle.main.path(forResource: "icons", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<String> {
                    icons = jsonResult
                }
            } catch {
                print("Error parsing json")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureIcons()
    }
}

extension IconsCollectionViewController {
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let icons = icons {
            return icons.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: IconCollectionViewCell.classForCoder()), for: indexPath) as! IconCollectionViewCell
        cell.configureImage(image: icon(index: indexPath.row))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate, let icons = icons {
            delegate.didSelectIcon(iconName: icons[indexPath.row])
            navigationController?.popViewController(animated: true)
        }
    }
}
