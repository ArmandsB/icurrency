//
//  CurrencyViewControllerSnapshotTests.swift
//  iCurrencyTests
//
//  Created by Armands Baurovskis on 29/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import FBSnapshotTestCase
import RxDataSources
import UIKit

@testable import iCurrency

class CurrencyViewControllerSnapshotTests: FBSnapshotTestCase {
  
  let service = CurrencyService(service: ApiClient.shared)
  var viewController: CurrencyViewController!
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
    viewController = CurrencyViewController(service: service)
    service.setEnvironment(environment: .test)
  }
  
  private func resizeViewController() {
    _ = viewController.view
    viewController.view.frame = CGRect(origin: .zero, size: TestConstants.iPhoneXSize)
    viewController.view.layoutIfNeeded()
  }
  
  func testShowSpinner() {
    self.resizeViewController()
    viewController.currencyView.showSpinner()
    viewController.currencyView.dismissError()
    
    let expectation = XCTestExpectation(description: "CurrencyViewController Main Queue")
    DispatchQueue.main.async {
      self.FBSnapshotVerifyView(self.viewController.view, identifier: "CurrencyViewController_spinner_iX")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testShowError() {
    service.setPredefiniedResponse(data: [Data()])
    self.resizeViewController()
    
    let expectation = XCTestExpectation(description: "CurrencyViewController Main Queue")
    DispatchQueue.main.async {
      self.FBSnapshotVerifyView(self.viewController.view, identifier: "CurrencyViewController_error_iX")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testBasicState() {
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    
    service.setPredefiniedResponse(data: [currenciesListData])
    self.resizeViewController()
    
    let expectation = XCTestExpectation(description: "CurrencyViewController Main Queue")
    delay(0.5) {
      self.FBSnapshotVerifyView(self.viewController.view, identifier: "CurrencyViewController_basic_iX")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testSelectDifferentCell() {
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    
    service.setPredefiniedResponse(data: [currenciesListData])
    self.resizeViewController()
    let expectation = XCTestExpectation(description: "CurrencyViewController Main Queue")

    
    DispatchQueue.main.async {
      self.viewController.currencyView.tableView.delegate?.tableView?(self.viewController.currencyView.tableView,
                                                                      didSelectRowAt: IndexPath(row: 1, section: 0))
      delay(0.5) {
        self.FBSnapshotVerifyView(self.viewController.view, identifier: "CurrencyViewController_select_diferrent_iX")
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: 2.0)
  }
}
