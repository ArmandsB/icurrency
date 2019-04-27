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
}

protocol CurrencyViewModelOutputs {
    var onShowError: Driver<String?> { get }
    var onShowSpinner: Driver<Bool> { get }
    var currencies: Driver<[Currency]> { get }
}

class CurrencyViewModel: CurrencyViewModelInputs, CurrencyViewModelOutputs {
    
    typealias TableViewSection = AnimatableSectionModel<String, Currency>
    
    let disposeBag = DisposeBag()
    let service: CurrencyServiceEndpoints
    let baseCurrency: String
    
    var onShowSpinner: Driver<Bool>
    private let onShowSpinnerPropery: BehaviorRelay<Bool> = .init(value: true)
    
    var onShowError: Driver<String?>
    private let onShowErrorProperty: BehaviorRelay<String?> = .init(value: nil)
    
    var currencies: Driver<[Currency]>
    private let currenciesProperty: BehaviorRelay<[Currency]> = .init(value: [])
    
    
    init(service: CurrencyServiceEndpoints, baseCurrency: String) {
        self.service = service
        self.baseCurrency = baseCurrency
        
        self.onShowSpinner = onShowSpinnerPropery.asDriver(onErrorJustReturn: false)
        self.onShowError = onShowErrorProperty.asDriver(onErrorJustReturn: nil)
        self.currencies = currenciesProperty.asDriver(onErrorJustReturn: [])
    }
    
    lazy var fetchDataAction: CocoaAction = {
        return CocoaAction { _ in
            return self.loadCurrencies(baseCurrency: self.baseCurrency)
                .flatMap {_ in
                    return Observable.just(())
            }
        }
    }()
    
    
}

private extension CurrencyViewModel {
    
    func loadCurrencies(baseCurrency: String) -> Observable<Void> {
        self.onShowErrorProperty.accept(nil)
        
        if self.currenciesProperty.value.isEmpty {
            self.onShowSpinnerPropery.accept(true)
        }
        
        return self.service.fetchCurrencies(baseCurrency: baseCurrency)
            .flatMap { [weak self] response ->  Observable<Void> in
                guard let self = self else { return .empty() }
                self.onShowSpinnerPropery.accept(false)
                
                switch response {
                case let .success(currencies):
                    self.currenciesProperty.accept(currencies)
                case .failure:
                    if self.currenciesProperty.value.isEmpty {
                        self.onShowErrorProperty.accept("Sorry, something went wrong")
                    }
                }
                return .just(())
        }
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
