//
//  CurrencyApiTests.swift
//  iCurrencyTests
//
//  Created by Armands Baurovskis on 29/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import XCTest
import RxSwift
@testable import iCurrency

class CurrencyApiTests: XCTestCase {
  
  let service = CurrencyService(service: ApiClient())
  let disposeBag = DisposeBag()
  
  override func setUp() {
    super.setUp()
    service.setEnvironment(environment: .test)
  }
  
  private func currencyList(data: Data, isSuccess: Bool) {
    let expectation = XCTestExpectation(description: "Home with mockup")
    service.setPredefiniedResponse(data: [data])
    service.fetchCurrencies(baseCurrency: "EUR")
      .subscribe(onNext: { response in
        switch response {
        case .success:
          XCTAssert(isSuccess)
          expectation.fulfill()
        case .failure:
          XCTAssert(!isSuccess)
          expectation.fulfill()
        }
        
      })
      .disposed(by: disposeBag)
    wait(for: [expectation], timeout: 3.0)
  }
  
  func testCurrencyListSuccess() {
    let bundle = Bundle(for: type(of: self))
    guard let billData = Data.json(bundle: bundle, fileName: TestMockups.currencyList1Success.rawValue) else {
      XCTAssert(false)
      return
    }
    
    self.currencyList(data: billData, isSuccess: true)
  }
  
  func testCurrencyListError() {
    let bundle = Bundle(for: type(of: self))
    guard let billData = Data.json(bundle: bundle, fileName: TestMockups.currencyListErorr.rawValue) else {
      XCTAssert(false)
      return
    }
    self.currencyList(data: billData, isSuccess: false)
  }
  
}
