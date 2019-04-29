//
//  CurrencyServiceEndpoints.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation
import RxSwift

protocol CurrencyServiceEndpoints {
  func fetchCurrencies(baseCurrency: String) -> Observable<Result<[Currency], ApiError>>
}
