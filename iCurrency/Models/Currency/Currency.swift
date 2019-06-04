//
//  Currency.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation
import RxDataSources

struct Currency: Equatable {
  let name: String
  let rate: Double

  static func == (lhs: Currency, rhs: Currency) -> Bool {
    return lhs.name == rhs.name
  }
}
