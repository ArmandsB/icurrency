//
//  CurrencyService.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation
import RxSwift

class CurrencyService: ApiService  {
    
    let service: ApiClient
    init(service: ApiClient) {
        self.service = service
    }
}

extension CurrencyService: CurrencyServiceEndpoints {
    
    func fetchCurrencies(baseCurrency: String) -> Observable<Result<[Currency], ApiError>> {
        let apiRequest = ApiRequest(method: .GET,
                                    endpoint: "latest",
                                    parameters: ["base": baseCurrency])
        return self.service.request(request: apiRequest, type: JSON.self)
            .flatMap { response -> Observable<Result<[Currency], ApiError>> in
                switch response {
                case let .success(data):
                    var currencies: [Currency] = []
                    if let rates = data["rates"] as? JSON {
                        currencies.append(Currency(name: baseCurrency, rate: 1.0000))
                        let keys = Array(rates.keys).sorted()
                        keys.forEach { key in
                            let value = rates[key] as? Double ?? 0.0
                            currencies.append(Currency(name: key, rate: value))
                        }
                    }
                    return .just(.success(currencies))
                case let .failure(error):
                    return Observable.just(.failure(error))
                }
            }
    }
}
