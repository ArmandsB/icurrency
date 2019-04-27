//
//  CurrencyCellViewModel.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CurrencyCellViewModelInput {
    func merge(currency: Currency)
}

protocol CurrencyCellViewModelOutput {
    var currency: Observable<Currency> { get }
    var titleAttributedString: Observable<NSAttributedString> { get }
    var valueAttributedString: Observable<NSAttributedString> { get }
    var rateAttributedString: Observable<NSAttributedString> { get }
}

class CurrencyCellViewModel: CurrencyCellViewModelInput, CurrencyCellViewModelOutput {
    
    var currency: Observable<Currency>
    private let currencyProperty: BehaviorRelay<Currency>
    
    var titleAttributedString: Observable<NSAttributedString>
    var valueAttributedString: Observable<NSAttributedString>
    var rateAttributedString: Observable<NSAttributedString>
    
    init(currency: Currency, activeCurrencyObservable: Observable<CurrencyCellViewModelType>) {
        currencyProperty = .init(value: currency)
        self.currency = currencyProperty.asObservable()
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = ""
        
        titleAttributedString = currencyProperty.map({ currency -> NSAttributedString in
            return NSAttributedString(string: currency.name,
                                      attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
        })
        
        valueAttributedString = currencyProperty.map({ currency -> NSAttributedString in
            return NSAttributedString(string: currency.name,
                                      attributes: [.font: UIFont.preferredFont(forTextStyle: .title3)])
        })
        
        rateAttributedString = currencyProperty.map({ currency -> NSAttributedString in
            return NSAttributedString(string: currencyFormatter.string(from: NSNumber(value: currency.rate)) ?? " - ",
                                      attributes: [.font: UIFont.preferredFont(forTextStyle: .footnote),
                                                   .foregroundColor: UIColor.gray ])
        })
    }
    
    func merge(currency: Currency) {
        self.currencyProperty.accept(currency)
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
