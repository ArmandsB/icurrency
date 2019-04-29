//
//  CurrencyViewModel.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Action
import Foundation
import RxCocoa
import RxSwift
import RxDataSources

protocol CurrencyViewModelInputs {
  var fetchDataAction: CocoaAction { get }
  var selectCurrency: Action<CurrencyCellViewModelType, Void> { get }
}

protocol CurrencyViewModelOutputs {
  var onShowError: Driver<String?> { get }
  var onShowSpinner: Driver<Bool> { get }
  var currencies: Driver<[CurrencyCellViewModel]> { get }
  var activeCurrency: Observable<CurrencyCellViewModelType?> { get }
}

class CurrencyViewModel: CurrencyViewModelInputs, CurrencyViewModelOutputs {

  typealias TableViewSection = AnimatableSectionModel<String, CurrencyCellViewModel>

  let disposeBag = DisposeBag()
  let service: CurrencyServiceEndpoints
  let baseCurrency: String

  var onShowSpinner: Driver<Bool>
  private let onShowSpinnerPropery: BehaviorRelay<Bool> = .init(value: true)

  var onShowError: Driver<String?>
  private let onShowErrorProperty: BehaviorRelay<String?> = .init(value: nil)

  var currencies: Driver<[CurrencyCellViewModel]>
  private let currenciesProperty: BehaviorRelay<[CurrencyCellViewModel]> = .init(value: [])

  var activeCurrency: Observable<CurrencyCellViewModelType?>
  private let activeCurrencyProperty: BehaviorRelay<CurrencyCellViewModelType?> = .init(value: nil)

  init(service: CurrencyServiceEndpoints, baseCurrency: String) {
    self.service = service
    self.baseCurrency = baseCurrency

    self.onShowSpinner = onShowSpinnerPropery.asDriver(onErrorJustReturn: false)
    self.onShowError = onShowErrorProperty.asDriver(onErrorJustReturn: nil)
    self.currencies = currenciesProperty.asDriver(onErrorJustReturn: [])
    self.activeCurrency = activeCurrencyProperty.asObservable().share(replay: 1)
  }

  lazy var fetchDataAction: CocoaAction = {
    return CocoaAction { _ in
      return self.loadCurrencies(baseCurrency: self.baseCurrency)
    }
  }()

  lazy var selectCurrency: Action<CurrencyCellViewModelType, Void> = {
    return Action<CurrencyCellViewModelType, Void> { input in
      guard let index = self.currenciesProperty.value
        .firstIndex(where: { $0.outputs.currency.value == input.outputs.currency.value }) else { return .empty() }

      var currencies = self.currenciesProperty.value
      let selectedCurrency = currencies[index]
      currencies.remove(at: index)
      currencies.insert(selectedCurrency, at: 0)
      self.currenciesProperty.accept(currencies)
      self.activeCurrencyProperty.accept(input)
      return .just(())
    }
  }()

}

private extension CurrencyViewModel {

  func loadCurrencies(baseCurrency: String) -> Observable<Void> {
    if self.onShowErrorProperty.value != nil {
      self.onShowErrorProperty.accept(nil)
    }

    if self.currenciesProperty.value.isEmpty {
      self.onShowSpinnerPropery.accept(true)
    }

    return self.service.fetchCurrencies(baseCurrency: baseCurrency)
      .flatMap { [weak self] response ->  Observable<Void> in
        guard let self = self else { return .just(()) }
        self.onShowSpinnerPropery.accept(false)

        switch response {
        case let .success(currencies):

          var currenciesCellViewModels = self.mergeCurrencies(cellViewModels: self.currenciesProperty.value,
                                                              currencies: currencies)

          if self.activeCurrencyProperty.value == nil {
            let activeCellViewModel = currenciesCellViewModels
              .first(where: { $0.outputs.currency.value.name == self.baseCurrency })
            self.activeCurrencyProperty.accept(activeCellViewModel)
            activeCellViewModel?.inputs.editInputValue(input: 1000)
          }

          if let activeCurrency = self.activeCurrencyProperty.value,
            let index = currenciesCellViewModels
              .firstIndex(where: { $0.outputs.currency.value == activeCurrency.outputs.currency.value }) {

            let moveCurrency = currenciesCellViewModels[index]
            currenciesCellViewModels.remove(at: index)
            currenciesCellViewModels.insert(moveCurrency, at: 0)
          }

          self.currenciesProperty.accept(currenciesCellViewModels)

        case .failure:
          if self.currenciesProperty.value.isEmpty {
            self.onShowErrorProperty.accept("Sorry, something went wrong")
          }
        }
        return .just(())
    }
  }

  func mergeCurrencies(cellViewModels: [CurrencyCellViewModel], currencies: [Currency]) -> [CurrencyCellViewModel] {
    var currenciesCellViewModels = cellViewModels
    currencies.forEach { currency in
      let cellViewModel = currenciesCellViewModels.first(where: { model -> Bool in
        return model.outputs.currency.value == currency
      })

      if cellViewModel == nil {
        currenciesCellViewModels.append(CurrencyCellViewModel(currency: currency,
                                                              activeCurrencyObservable: self.activeCurrency))
      } else {
        cellViewModel?.inputs.merge(currency: currency)
      }
    }

    return currenciesCellViewModels
  }
}

protocol CurrencyViewModelType {
  var inputs: CurrencyViewModelInputs { get }
  var outputs: CurrencyViewModelOutputs { get }
}

extension CurrencyViewModel: CurrencyViewModelType {
  var inputs: CurrencyViewModelInputs { return self }
  var outputs: CurrencyViewModelOutputs { return self }
}
