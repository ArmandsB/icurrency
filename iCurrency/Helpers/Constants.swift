//
//  Constants.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

struct Constants {

  struct URLs {
    static let currencyApi = URL(string: "https://api.exchangeratesapi.io")!
  }

  struct Tests {

    static func isUnitTesting() -> Bool {
      return ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil
    }
  }
}

func delay(_ delay: Double, execute: @escaping () -> Void) {
  let when = DispatchTime.now() + delay
  DispatchQueue.main.asyncAfter(deadline: when, execute: execute)
}
