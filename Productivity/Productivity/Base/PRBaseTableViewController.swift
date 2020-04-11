//
//  PRBaseTableViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

open class PRBaseTableViewController: UITableViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.configureAccessibilityIdentifiers()
        setTableView()
    }
    
    func setTableView() {
        tableView.contentInset.top = 20
        tableView.backgroundColor = UIColor(red: 0.157, green: 0.161, blue: 0.165, alpha: 1.00)
        tableView.separatorColor = .clear
    }
    
    // MARK: - Table view data source
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 0    //Handle in subclass
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0    //Handle in subclass
    }
}
