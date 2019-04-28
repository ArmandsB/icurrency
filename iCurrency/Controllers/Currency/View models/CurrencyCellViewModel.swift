//
//  CurrencyCellViewModel.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Action
import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol CurrencyCellViewModelInput {
    func merge(currency: Currency)
    func setInputValue(input: Double)
}

protocol CurrencyCellViewModelOutput {
    var currency: BehaviorRelay<Currency> { get }
    var inputValue: Observable<Double> { get }
    var titleAttributedString: Observable<NSAttributedString> { get }
    var valueAttributedString: Observable<NSAttributedString> { get }
    var rateAttributedString: Observable<NSAttributedString> { get }
    var isActive: Observable<Bool> { get }
}

class CurrencyCellViewModel: CurrencyCellViewModelInput, CurrencyCellViewModelOutput {
    var currency: BehaviorRelay<Currency>
    var titleAttributedString: Observable<NSAttributedString>
    var valueAttributedString: Observable<NSAttributedString>
    var rateAttributedString: Observable<NSAttributedString>
    
    var isActive: Observable<Bool>
    private let isActiveProperty: BehaviorRelay<Bool> = .init(value: false)
    
    var inputValue: Observable<Double>
    private let inputValueProperty: BehaviorRelay<Double> = .init(value: 0)
    
    private let activeCurrencyObservable: Observable<CurrencyCellViewModel?>
    
    let disposeBag = DisposeBag()
    private var disposeableInputSubscribe: Disposable?
    
    init(currency: Currency, activeCurrencyObservable: Observable<CurrencyCellViewModel?>) {
        self.currency = .init(value: currency)
        self.activeCurrencyObservable = activeCurrencyObservable
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.groupingSeparator = " "
        currencyFormatter.minimumFractionDigits = 4
        currencyFormatter.maximumFractionDigits = 4
        
        titleAttributedString = self.currency.map({ currency -> NSAttributedString in
            return NSAttributedString(string: currency.name,
                                      attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
        })
        
        
        isActive = isActiveProperty.asObservable()
        inputValue = inputValueProperty.asObservable()
        
        valueAttributedString = inputValue.map({ value -> NSAttributedString in
            let convertRateFormatted = currencyFormatter.string(from: NSNumber(value: value)) ?? " - "
            return NSAttributedString(string: convertRateFormatted,
                                      attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
        })
        
        let activeCurrencyObservable = self.activeCurrencyObservable
            .flatMap { activeCurrenyOptional  -> Observable<CurrencyCellViewModel> in
                guard let activeCurrency = activeCurrenyOptional else { return .empty() }
                return .just(activeCurrency)
            }
        
        let zipCurrenyAndActive = Observable.combineLatest(self.currency.asObservable(), activeCurrencyObservable) { ($0, $1) }
        rateAttributedString = zipCurrenyAndActive.map({ currency, activeCurrency -> NSAttributedString in
            let convertRate = currency.converRate(to: activeCurrency.currency.value)
            let convertRateFormatted = currencyFormatter.string(from: NSNumber(value: convertRate)) ?? " - "
            let text = "1 \(currency.name) = \(convertRateFormatted) \(activeCurrency.currency.value.name)"
            return NSAttributedString(string: text,
                                      attributes: [.font: UIFont.preferredFont(forTextStyle: .footnote),
                                                   .foregroundColor: UIColor.gray ])
        })
        
        self.subscribeActiveCurrencyInputChange()
        
        activeCurrencyObservable
            .subscribe(onNext: { [weak self] activeCurrencyObservable in
                guard let self = self else { return }
                let activeCurrency = activeCurrencyObservable.outputs.currency.value
                self.isActiveProperty.accept(activeCurrency == self.currency.value)
            })
            .disposed(by: disposeBag)
    }
    
    func merge(currency: Currency) {
        self.currency.accept(currency)
    }
    
    func setInputValue(input: Double) {
        guard self.isActiveProperty.value else { return }
        self.inputValueProperty.accept(input)
    }

    
    private func subscribeActiveCurrencyInputChange() {
        let activeCurrencyObservable = self.activeCurrencyObservable
            .flatMap { activeCurrenyOptional  -> Observable<CurrencyCellViewModel> in
                guard let activeCurrency = activeCurrenyOptional else { return .empty() }
                return .just(activeCurrency)
            }
        
        activeCurrencyObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] activeCurrencyModel in
                guard let self = self else { return }
                self.disposeableInputSubscribe?.dispose()
                let currency = self.currency.value
                let activeCurrency = activeCurrencyModel.outputs.currency.value
                guard activeCurrency != currency else { return }
                
                // To prevent endless loop, at beginning we listen for the active currency and then listen its input value.
                
                let combine = Observable.combineLatest(activeCurrencyModel.outputs.inputValue,
                                                       activeCurrencyModel.outputs.currency.asObservable(),
                                                       self.currency.asObservable()) { ($0, $1, $2) }
                self.disposeableInputSubscribe = combine
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self] newInputValue, activeCurrency, currency in
                        guard let self = self, newInputValue > 0 else { return }
                        let rate = activeCurrency.converRate(to: currency)
                        self.inputValueProperty.accept(rate * newInputValue)
                    })
            })
            .disposed(by: disposeBag)
    }
}

extension CurrencyCellViewModel: Equatable {
    static func ==(lhs: CurrencyCellViewModel, rhs: CurrencyCellViewModel) -> Bool {
        return lhs.outputs.currency.value == rhs.outputs.currency.value
    }
}

extension CurrencyCellViewModel: IdentifiableType {
    var identity: String {
        return self.currency.value.name
    }
}

protocol CurrencyCellViewModelType {
    var inputs: CurrencyCellViewModelInput { get }
    var outputs: CurrencyCellViewModelOutput { get }
}

extension CurrencyCellViewModel: CurrencyCellViewModelType {
    var inputs: CurrencyCellViewModelInput { return self }
    var outputs: CurrencyCellViewModelOutput { return self }
}
