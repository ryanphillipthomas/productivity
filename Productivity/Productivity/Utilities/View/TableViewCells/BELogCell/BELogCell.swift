//
//  BELogCell.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/21/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

class BELogCell: UITableViewCell {

    @IBOutlet weak var statusCodeLabel: UILabel!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var endpointTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Style
    func setStyles() {
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        layer.cornerRadius = 5.0
    }

    //MARK: Configure View
    func configureView(node: LogQueueNode) {
        setStyles()
        setStatusCode(code: node.statusCode)
        endpointLabel.text = node.url
        endpointTypeLabel.text = node.httpMethod
    }
    
    func setStatusCode(code: Int?) {
        if let code = code {
            statusCodeLabel.text = String(describing: code)
            layer.borderColor = !(code < 300 && code > 199) ? UIColor.red.cgColor : UIColor.clear.cgColor
            layer.borderWidth = !(code < 300 && code > 199) ? 2.0 : 0.0
        } else {
            statusCodeLabel.text = "N/A"
        }
    }
}
