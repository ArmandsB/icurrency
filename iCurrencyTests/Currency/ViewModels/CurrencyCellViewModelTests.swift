//
//  CurrencyCellViewModelTests.swift
//  iCurrencyTests
//
//  Created by Armands Baurovskis on 29/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import RxBlocking
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import iCurrency

class CurrencyCellViewModelTests: XCTestCase {

  let disposeBag = DisposeBag()
  let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModelType?> = .init(value: nil)
  var activeCurrencyObservable: Observable<CurrencyCellViewModelType?>!
  var viewModel: CurrencyCellViewModelType!
  var scheduler: TestScheduler!
  
  override func setUp() {
    super.setUp()
    scheduler = TestScheduler(initialClock: 0)
    activeCurrencyObservable = activeCurrencyProperty.asObservable()
    let currency = Currency(name: "EUR", rate: 1.1234)
    viewModel = CurrencyCellViewModel(currency: currency,
                                      activeCurrencyObservable: activeCurrencyObservable)
    
  }
  
  func testIfEqual() {
    guard let viewModel = self.viewModel as? CurrencyCellViewModel else {
      XCTFail()
      return
    }
    
    var currency = Currency(name: "EUR", rate: 1.1234)
    let equalViewModel = CurrencyCellViewModel(currency: currency,
                                               activeCurrencyObservable: activeCurrencyObservable)
    
    currency = Currency(name: "USD", rate: 1.1111)
    let notEqualViewModel = CurrencyCellViewModel(currency: currency,
                                                 activeCurrencyObservable: activeCurrencyObservable)
    
    XCTAssertEqual(viewModel, equalViewModel)
    XCTAssertNotEqual(viewModel, notEqualViewModel)
  }
}

// MARK: Inputs

extension CurrencyCellViewModelTests {

  func testMergeCurrency() {
    XCTAssertEqual(viewModel.outputs.currency.value.rate, 1.1234)
    let currency = Currency(name: "EUR", rate: 1.1111)
    viewModel.inputs.merge(currency: currency)
    XCTAssertEqual(viewModel.outputs.currency.value.rate, 1.1111)
  }
  
  func testEditInputValueSelected() {
    XCTAssertEqual(try viewModel.outputs.inputValue.toBlocking().first(), 0.0000)
    activeCurrencyProperty.accept(viewModel)
    
    let inputValueObserver = scheduler.createObserver(Double.self)
    viewModel.outputs.inputValue
      .subscribe(inputValueObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.editInputValue(input: 1000)
    
    let record = inputValueObserver.events.last!.value.element!
    XCTAssertEqual(record, 1000)
  }
  
  func testEditInputValueWhenNotSelected() {
    XCTAssertEqual(try viewModel.outputs.inputValue.toBlocking().first(), 0.0000)
    
    let inputValueObserver = scheduler.createObserver(Double.self)
    viewModel.outputs.inputValue
      .subscribe(inputValueObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.editInputValue(input: 1000)
    
    let record = inputValueObserver.events.last!.value.element!
    XCTAssertEqual(record, 0)
  }
}

// MARK: Outputs

extension CurrencyCellViewModelTests {
  
  func testCurrencyOuput() {
    XCTAssertEqual(viewModel.outputs.currency.value.name, "EUR")
    XCTAssertEqual(viewModel.outputs.currency.value.rate, 1.1234)
    
    let currenyObserver = scheduler.createObserver(Currency.self)
    viewModel.outputs.currency
      .subscribe(currenyObserver)
      .disposed(by: disposeBag)
    let currency = Currency(name: "USD", rate: 1.1111)
    viewModel.inputs.merge(currency: currency)
    
    let record = currenyObserver.events.last!.value.element!
    XCTAssertEqual(record.name, "USD")
    XCTAssertEqual(record.rate, 1.1111)
  }
  
  func testInputValueOuput() {
    XCTAssertEqual(try viewModel.outputs.inputValue.toBlocking().first(), 0.0000)
    activeCurrencyProperty.accept(viewModel)
    
    let inputValueObserver = scheduler.createObserver(Double.self)
    viewModel.outputs.inputValue
      .subscribe(inputValueObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.editInputValue(input: 1000)
    
    let record = inputValueObserver.events.last!.value.element!
    XCTAssertEqual(record, 1000)
  }
  
  func testTitleAttributedString() {
    var titleAttributedString = NSAttributedString(string: "EUR",
                                                   attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
    
    XCTAssertEqual(try viewModel.outputs.titleAttributedString.toBlocking().first(), titleAttributedString)
    let currency = Currency(name: "USD", rate: 1.1111)
    
    let titleObserver = scheduler.createObserver(NSAttributedString.self)
    viewModel.outputs.titleAttributedString
      .subscribe(titleObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.merge(currency: currency)
    
    titleAttributedString = NSAttributedString(string: currency.name,
                                              attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
    
    let record = titleObserver.events.last!.value.element!
    XCTAssertEqual(record, titleAttributedString)
  }
  
  func testValueAttributedString() {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = .decimal
    currencyFormatter.groupingSeparator = " "
    currencyFormatter.minimumFractionDigits = 4
    currencyFormatter.maximumFractionDigits = 4
    
    var valueAttributedString = NSAttributedString(string: currencyFormatter.string(from: NSNumber(value: 0)) ?? " - ",
                                                   attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
    
    XCTAssertEqual(try viewModel.outputs.valueAttributedString.toBlocking().first(), valueAttributedString)
    activeCurrencyProperty.accept(viewModel)
    
    let valueObserver = scheduler.createObserver(NSAttributedString.self)
    viewModel.outputs.valueAttributedString
      .subscribe(valueObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.editInputValue(input: 1000)
    
    valueAttributedString = NSAttributedString(string: currencyFormatter.string(from: NSNumber(value: 1000)) ?? " - ",
                                               attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
    
    let record = valueObserver.events.last!.value.element!
    XCTAssertEqual(record, valueAttributedString)
  }
  
  func testRateAttributedString() {
    
    let activeCurrency = Currency(name: "EUR", rate: 1)
    let activeViewModel = CurrencyCellViewModel(currency: activeCurrency,
                                      activeCurrencyObservable: activeCurrencyObservable)
    activeCurrencyProperty.accept(activeViewModel)
    
    let currency = Currency(name: "USD", rate: 1.1111)
    viewModel.inputs.merge(currency: currency)
    
    let rateObserver = scheduler.createObserver(NSAttributedString.self)
    viewModel.outputs.rateAttributedString
      .subscribe(rateObserver)
      .disposed(by: disposeBag)
    
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = .decimal
    currencyFormatter.groupingSeparator = " "
    currencyFormatter.minimumFractionDigits = 4
    currencyFormatter.maximumFractionDigits = 4
    
    let convertRate = currency.converRate(to: activeCurrency)
    let convertRateFormatted = currencyFormatter.string(from: NSNumber(value: convertRate)) ?? " - "
    let text = "1 \(currency.name) = \(convertRateFormatted) \(activeCurrency.name)"
    
    let rateAttributedString = NSAttributedString(string: text,
                                                  attributes: [.font: UIFont.preferredFont(forTextStyle: .footnote),
                                                               .foregroundColor: UIColor.gray ])
    
    let record = rateObserver.events.last!.value.element!
    XCTAssertEqual(record, rateAttributedString)
  }
  
  func testIsActive() {
    XCTAssertEqual(try viewModel.outputs.isActive.toBlocking().first(), false)
    activeCurrencyProperty.accept(viewModel)
    
    let isActiveObserver = scheduler.createObserver(Bool.self)
    viewModel.outputs.isActive
      .subscribe(isActiveObserver)
      .disposed(by: disposeBag)
    
    activeCurrencyProperty.accept(viewModel)
    
    let record = isActiveObserver.events.last!.value.element!
    XCTAssertEqual(record, true)
  }
}
