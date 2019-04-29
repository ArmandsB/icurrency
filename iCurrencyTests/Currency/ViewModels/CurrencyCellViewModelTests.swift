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
  let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModel?> = .init(value: nil)
  var activeCurrencyObservable: Observable<CurrencyCellViewModel?>!
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
}


// MARK: Inputs

extension CurrencyCellViewModelTests {

}
