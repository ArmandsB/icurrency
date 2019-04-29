//
//  CurrencyView.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import SnapKit
import UIKit

class CurrencyView: UIView {
  
  let tableView = UITableView(frame: .zero, style: .plain)
  private var errorLabel: UILabel?
  private var spinnerView: UIActivityIndicatorView?
  
  init() {
    super.init(frame: .zero)
    self.backgroundColor = UIColor.groupTableViewBackground
    
    self.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CurrencyView {
  
  func showSpinner() {
    guard spinnerView == nil else { return }
    let spinnerView = UIActivityIndicatorView(style: .gray)
    spinnerView.startAnimating()
    
    self.addSubview(spinnerView)
    spinnerView.snp.makeConstraints { make in
      make.center.equalTo(self.snp.center)
    }
    
    self.spinnerView = spinnerView
  }
  
  func dismissSpinner() {
    guard let spinnerView = self.spinnerView else { return }
    spinnerView.removeFromSuperview()
    self.spinnerView = nil
  }
}

extension CurrencyView {
  
  func showError(error: String) {
    let text = NSAttributedString(string: error,
                                  attributes: [.foregroundColor: UIColor.gray,
                                               .font: UIFont.preferredFont(forTextStyle: .body)])
    guard errorLabel == nil else {
      errorLabel?.attributedText = text
      return
    }
    
    let errorLabel = UILabel()
    errorLabel.textAlignment = .center
    errorLabel.attributedText = text
    self.addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.edges.equalTo(self.snp.margins)
    }
    
    self.errorLabel = errorLabel
  }
  
  func dismissError() {
    guard let errorLabel = errorLabel else { return }
    errorLabel.removeFromSuperview()
    self.errorLabel = nil
  }
}
