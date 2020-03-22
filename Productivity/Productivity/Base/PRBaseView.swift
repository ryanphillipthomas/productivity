//
//  PRBaseView.swift
//  Productivity
//
//  Created by Ryan Thomas on 3/17/20.
//  Copyright © 2020 Ryan Thomas. All rights reserved.
//

import UIKit

/*
 The majority of views should have their accessibility identifiers handled through the recursion done by the view controller.
 In the event that any subviews are added AFTER the viewDidLoad of the controller is called, those subviews will need a manual
 configureAccessibilityIdenfitiers.
 
 Ex: StackView added an arranged subview after the viewDidLoad in a controller
 */

open class PRBaseView: UIView {
  
  // MARK: -
  // MARK: Template -
  
  public func configureViews() {}
  public func cleanViews() {}
  public func customize(any: Any?) {}
  
  // MARK: -
  // MARK: Init -
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureViews()
  }
  
  override open func awakeFromNib() {
    super.awakeFromNib()
    configureViews()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    translatesAutoresizingMaskIntoConstraints = false
    accessibilityIdentifier = "PR_\(self.nameOfClass)"
    backgroundColor = .white
    configureViews()
  }
  
  public convenience init() {
    self.init(frame: .zero)
  }
  
}
