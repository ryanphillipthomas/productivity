//
//  LoggerViewController.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

public class LoggerViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var fileContainerView: UIView!
    @IBOutlet weak var logTableView: UITableView!
    
    
    //MARK: View Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    //MARK: Configure View
    func configureView() {
        configureTableView()
    }
    
    func configureTableView() {
        logTableView.delegate = self
        logTableView.dataSource = self
        logTableView.register(UINib(nibName: String(describing: BELogCell.self), bundle: Bundle(for: self.classForCoder)), forCellReuseIdentifier: String(describing: BELogCell.self))
    }
    
    //MARK: IBActions
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LoggerViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return LogManager.shared().logQueue.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = LogManager.shared().logQueue[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BELogCell.self), for: indexPath) as! BELogCell
        cell.configureView(node: node)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Constants.Storyboards.logStoryboard.instantiateViewController(withIdentifier: String(describing: LoggerDetailsViewController.self)) as! LoggerDetailsViewController
        vc.logNode = LogManager.shared().logQueue[indexPath.section]
        present(vc, animated: true, completion: nil)
    }
}
