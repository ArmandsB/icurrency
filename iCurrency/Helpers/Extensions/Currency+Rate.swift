//
//  Currency+Rate.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 04/06/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation

extension Currency {
  func convertRate(to currency: Currency) -> Double {
    return currency.rate / self.rate
  }
}
