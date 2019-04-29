//
//  UITextField+DoneButton.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 28/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import UIKit

extension UITextField {
  typealias SelectionAction = (target: Any, action: Selector)
  
  func addDoneToolbar(onDone: SelectionAction? = nil) {
    let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
    let toolbar: UIToolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.items = [
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
      UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
    ]
    toolbar.sizeToFit()
    self.inputAccessoryView = toolbar
  }
  
  // Default actions:
  @objc func doneButtonTapped() { self.resignFirstResponder() }
}
