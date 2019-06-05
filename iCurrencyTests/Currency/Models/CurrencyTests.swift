//
//  CurrencyTests.swift
//  iCurrencyTests
//
//  Created by Armands Baurovskis on 29/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import XCTest
@testable import iCurrency

class CurrencyTests: XCTestCase {
  
  func testCurrencyModel() {
    
    let currency1 = Currency(name: "EUR", rate: 1.1234)
    let currency2 = Currency(name: "EUR", rate: 1.1234)
    let currency3 = Currency(name: "USD", rate: 1.1111)
    
    XCTAssertEqual(currency1.name, "EUR")
    XCTAssertEqual(currency1.rate, 1.1234)
    XCTAssertEqual(currency1, currency2)
    XCTAssertNotEqual(currency1, currency3)
  }
  
  func testCurrencyConvert() {
    let currency1 = Currency(name: "CZK", rate: 1.4543)
    let currency2 = Currency(name: "USD", rate: 1.1111)
    let roundRate = Double(round(10000*currency1.convertRate(to: currency2))/10000)
    XCTAssertEqual(roundRate, 0.7640)
  }
}
