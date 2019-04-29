//
//  CurrencyTableViewCellSnapshotTests.swift
//  iCurrencyTests
//
//  Created by Armands Baurovskis on 29/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import FBSnapshotTestCase
import RxCocoa
import RxSwift
import XCTest

@testable import iCurrency

class CurrencyTableViewCellSnapshotTests: FBSnapshotTestCase {
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
  }
  
  func testUnactiveTableViewCell() {
    let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModel?> = .init(value: nil)
    let activeCurrencyObservable = activeCurrencyProperty.asObservable()
    let activeCurrency = Currency(name: "EUR", rate: 1.12345)
    let activeCellVieModel = CurrencyCellViewModel(currency: activeCurrency,
                                                   activeCurrencyObservable: activeCurrencyObservable)
    activeCurrencyProperty.accept(activeCellVieModel)
    
    let unactiveCurrency = Currency(name: "USD", rate: 1.1111)
    let unactiveCurrencyCellViewModel = CurrencyCellViewModel(currency: unactiveCurrency,
                                                              activeCurrencyObservable: activeCurrencyObservable)
    
    activeCellVieModel.inputs.setInputValue(input: 1000)
    
    let tableViewCell = CurrencyTableViewCell(style: .default, reuseIdentifier: "Cell")
    tableViewCell.cellViewModel = unactiveCurrencyCellViewModel
    tableViewCell.frame = CGRect(origin: .zero, size: CGSize(width: TestConstants.iPhoneXSize.width, height: 80))
    tableViewCell.layoutIfNeeded()
    
    let expectation = XCTestExpectation(description: "CurrencyTableViewCell Main Queue")
    DispatchQueue.main.async {
      self.FBSnapshotVerifyView(tableViewCell, identifier: "CurrencyTableViewCell_unactive_iX")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testActiveTableViewCell() {
    let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModel?> = .init(value: nil)
    let activeCurrencyObservable = activeCurrencyProperty.asObservable()
    let activeCurrency = Currency(name: "EUR", rate: 1.12345)
    let activeCellVieModel = CurrencyCellViewModel(currency: activeCurrency,
                                                   activeCurrencyObservable: activeCurrencyObservable)
    activeCurrencyProperty.accept(activeCellVieModel)
    activeCellVieModel.inputs.setInputValue(input: 1000)
    
    let tableViewCell = CurrencyTableViewCell(style: .default, reuseIdentifier: "Cell")
    tableViewCell.cellViewModel = activeCellVieModel
    tableViewCell.frame = CGRect(origin: .zero, size: CGSize(width: TestConstants.iPhoneXSize.width, height: 80))
    tableViewCell.layoutIfNeeded()
    
    let expectation = XCTestExpectation(description: "CurrencyTableViewCell Main Queue")
    DispatchQueue.main.async {
      self.FBSnapshotVerifyView(tableViewCell, identifier: "CurrencyTableViewCell_active_iX")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
