//
//  ApiClient.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation
import RxSwift

enum ApiError: Error {
  case invalidRequest
  case invalidResponse
  case urlRequest(Error)
}

class ApiClient {
  
  enum Environment {
    case live
    case test
  }
  
  static let shared = ApiClient()
  private let baseURL = Constants.URLs.currencyApi
  
  var environment: Environment = .live
  var predefiniedResponse: [Data] = []
  
  func request<T>(request: ApiRequest, type: T.Type) -> Observable<Result<T, ApiError>> {
    return Observable<Result<T, ApiError>>.create { [unowned self] observer in
      var task: URLSessionDataTask?
      
      if let urlReqeust = request.urlReqeust(baseURL: self.baseURL) {
        
        #if DEBUG
        print("\n\n===== REQUEST ====== \n\n\(urlReqeust.url?.absoluteString ?? "")")
        #endif
        
        let proccessBlock: (Data, AnyObserver<Result<T, ApiError>>) -> Void = { data, observer in
          do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? T {
              observer.onNext(.success(json))
              
              #if DEBUG
              print("\n\n===== RESPONSE ====== \n\n\(json)")
              #endif
            } else {
              observer.onNext(.failure(.invalidResponse))
            }
          } catch {
            observer.onNext(.failure(.invalidResponse))
          }
        }
        
        if self.environment == .test, let data = self.predefiniedResponse.first {
          proccessBlock(data, observer)
          self.predefiniedResponse.remove(at: 0)
          observer.onCompleted()
        } else {
          task = URLSession.shared.dataTask(with: urlReqeust) { data, response, error in
            if let error = error {
              let apiError: ApiError = .urlRequest(error)
              observer.onNext(.failure(apiError))
            } else if let data = data {
              proccessBlock(data, observer)
            } else {
              observer.onNext(.failure(.invalidRequest))
            }
            observer.onCompleted()
          }
          task?.resume()
        }
      } else {
        observer.onNext(.failure(.invalidRequest))
        observer.onCompleted()
      }
      
      
      return Disposables.create {
        task?.cancel()
      }
    }
  }
  
  
}
