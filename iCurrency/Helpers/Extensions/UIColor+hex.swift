//
//  UIColor+hex.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 28/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import UIKit

extension UIColor {
  public convenience init?(hex: String) {
    let rColor, gColor, bColor, alpha: CGFloat

    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])

      if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          rColor = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          gColor = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          bColor = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          alpha = CGFloat(hexNumber & 0x000000ff) / 255

          self.init(red: rColor, green: gColor, blue: bColor, alpha: alpha)
          return
        }
      }
    }

    return nil
  }
}
