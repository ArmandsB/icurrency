//
//  KeyboardHandler.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 28/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardHandlerDelegate: class {
  func keyboardFrameDidChange(size: CGRect,
                              animation: UIView.AnimationCurve,
                              duration: TimeInterval,
                              userInfo: JSON)
}

class KeyboardHandler: NSObject {
  weak var delegate: KeyboardHandlerDelegate?
  var keyboardRect = CGRect.zero
  override init() {
    super.init()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(notification:)),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(notification:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification,
                                           object: nil)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(notification:)),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func keyboardWillShow(notification: Notification) {
    guard let userInfo = notification.userInfo as? JSON else { return }
    let rect: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    self.keyboardDidChangeFrame(notification: notification, rect: rect)
  }

  @objc private func keyboardWillHide(notification: Notification) {
    self.keyboardDidChangeFrame(notification: notification, rect: CGRect.zero)
  }

  private func keyboardDidChangeFrame(notification: Notification, rect: CGRect) {
    guard let userInfo = notification.userInfo as? JSON else { return }
    self.keyboardRect = rect
    let curveIntValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
    let durationValueFromInfo = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let curve = UIView.AnimationCurve(rawValue: curveIntValue) ?? .linear
    let duration: TimeInterval = TimeInterval(durationValueFromInfo)
    delegate?.keyboardFrameDidChange(size: rect, animation: curve, duration: duration, userInfo: userInfo)
  }
}

extension UIView.AnimationCurve {
  func toOptions() -> UIView.AnimationOptions {
    return UIView.AnimationOptions(rawValue: UInt(rawValue << 16))
  }
}
