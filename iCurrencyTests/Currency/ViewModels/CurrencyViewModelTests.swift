//
//  CurrencyViewModelTests.swift
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

class CurrencyViewModelTests: XCTestCase {

  let currencyService = CurrencyService(service: ApiClient())
  let disposeBag = DisposeBag()
  var viewModel: CurrencyViewModelType!
  var scheduler: TestScheduler!
  
  private func currencies(data: Data) -> [Currency] {
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON else { return [] }
    guard let rates = json["rates"] as? JSON else { return [] }
    var currencies: [Currency] = []
    currencies.append(Currency(name: "EUR", rate: 1.0000))
    let keys = Array(rates.keys).sorted()
    keys.forEach { key in
      let value = rates[key] as? Double ?? 0.0
      currencies.append(Currency(name: key, rate: value))
    }
    return currencies
  }
  
  override func setUp() {
    super.setUp()
    currencyService.setEnvironment(environment: .test)
    viewModel = CurrencyViewModel(service: currencyService, baseCurrency: "EUR")
    scheduler = TestScheduler(initialClock: 0)
  }
  
}

// MARK: Inputs

extension CurrencyViewModelTests {
  
  func testFetchDataAction() {
    XCTAssertEqual(try viewModel.outputs.currencies.toBlocking().first(), [])
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    
    let currenciesList: [Currency] = self.currencies(data: currenciesListData)
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    let currencies = scheduler.createObserver([CurrencyCellViewModel].self)
    viewModel.outputs.currencies
      .drive(currencies)
      .disposed(by: disposeBag)
    viewModel.inputs.fetchDataAction.execute()
    
    XCTAssertEqual(currencies.events.count, 2)
    
    let records = currencies.events.last!.value.element!
    XCTAssertEqual(records.count, currenciesList.count)
  }
  
  func testSelectCurrencyAction() {
    let currentActiveCurrency = try! viewModel.outputs.activeCurrency.toBlocking().first()!
    XCTAssertNil(currentActiveCurrency)
    
    let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModelType?> = .init(value: nil)
    let activeCurrencyObservable = activeCurrencyProperty.asObservable()
    let activeCurrency = Currency(name: "EUR", rate: 1.12345)
    let activeCellVieModel = CurrencyCellViewModel(currency: activeCurrency,
                                                   activeCurrencyObservable: activeCurrencyObservable)
    
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    _ = viewModel.inputs.fetchDataAction.execute().toBlocking()
    
    let activeCurrencyObserver = scheduler.createObserver(CurrencyCellViewModelType?.self)
    viewModel.outputs.activeCurrency
      .subscribe(activeCurrencyObserver)
      .disposed(by: disposeBag)
    viewModel.inputs.selectCurrency.execute(activeCellVieModel)
    
    XCTAssertEqual(activeCurrencyObserver.events.count, 2)
    let record = activeCurrencyObserver.events.last!.value.element!
    XCTAssertEqual(activeCellVieModel.currency.value, record!.outputs.currency.value)
  }
  
  func testSelectCurrencyEmptyAction() {
    let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModelType?> = .init(value: nil)
    let activeCurrencyObservable = activeCurrencyProperty.asObservable()
    let activeCurrency = Currency(name: "EUR", rate: 1.12345)
    let activeCellVieModel = CurrencyCellViewModel(currency: activeCurrency,
                                                   activeCurrencyObservable: activeCurrencyObservable)
    let activeCurrencyObserver = scheduler.createObserver(CurrencyCellViewModelType?.self)
    viewModel.outputs.activeCurrency
      .subscribe(activeCurrencyObserver)
      .disposed(by: disposeBag)
    viewModel.inputs.selectCurrency.execute(activeCellVieModel)
    
    XCTAssertEqual(activeCurrencyObserver.events.count, 1)
    let record = activeCurrencyObserver.events.last!.value.element!
    XCTAssertNil(record)
  }
  
}

// MARK: Outputs

extension CurrencyViewModelTests {

  func testOnShowError() {
    XCTAssertNil(try! viewModel.outputs.onShowError.toBlocking().first()!)
    
    var currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyListErorr.rawValue) ?? Data()
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    
    let showErrorObserver = scheduler.createObserver(String?.self)
    viewModel.outputs.onShowError
      .drive(showErrorObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.fetchDataAction.execute()
    
    var record = showErrorObserver.events.last!.value.element!
    XCTAssertNotNil(record)
    
    currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    viewModel.inputs.fetchDataAction.execute()
    
    record = showErrorObserver.events.last!.value.element!
    XCTAssertNil(record)
  }
  
  func testOnShowSpinner() {
    XCTAssertEqual(try viewModel.outputs.onShowSpinner.toBlocking().first(), true)
    
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    
    let showSpinnerObserver = scheduler.createObserver(Bool.self)
    viewModel.outputs.onShowSpinner
      .drive(showSpinnerObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.fetchDataAction.execute()
    
    let record = showSpinnerObserver.events.last!.value.element!
    XCTAssertEqual(record, false)
  }
  
  func testCurrencies() {
    XCTAssertEqual(try viewModel.outputs.currencies.toBlocking().first(), [])
    
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    let currenciesList: [Currency] = self.currencies(data: currenciesListData)
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    
    let currenciesObserver = scheduler.createObserver([CurrencyCellViewModel].self)
    viewModel.outputs.currencies
      .drive(currenciesObserver)
      .disposed(by: disposeBag)
    
    viewModel.inputs.fetchDataAction.execute()
    
    let records = currenciesObserver.events.last!.value.element!
    XCTAssertEqual(records.count, currenciesList.count)
  }
  
  func testActiveCurrency() {
    let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModelType?> = .init(value: nil)
    let activeCurrencyObservable = activeCurrencyProperty.asObservable()
    let activeCurrency = Currency(name: "EUR", rate: 1.12345)
    let activeCellVieModel = CurrencyCellViewModel(currency: activeCurrency,
                                                   activeCurrencyObservable: activeCurrencyObservable)
    
    let currenciesListData = Data.json(bundle: Bundle(for: type(of: self)),
                                       fileName: TestMockups.currencyList1Success.rawValue) ?? Data()
    currencyService.setPredefiniedResponse(data: [currenciesListData])
    _ = viewModel.inputs.fetchDataAction.execute().toBlocking()
    
    let activeCurrencyObserver = scheduler.createObserver(CurrencyCellViewModelType?.self)
    viewModel.outputs.activeCurrency
      .subscribe(activeCurrencyObserver)
      .disposed(by: disposeBag)
    viewModel.inputs.selectCurrency.execute(activeCellVieModel)
    
    let record = activeCurrencyObserver.events.last!.value.element!
    XCTAssertEqual(activeCellVieModel.currency.value, record!.outputs.currency.value)
  }
}
