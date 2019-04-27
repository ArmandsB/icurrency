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
    
    static let shared = ApiClient()
    private let baseURL = Constants.URLs.currencyApi
    
    func request<T>(request: ApiRequest, type: T.Type) -> Observable<Result<T, ApiError>> {
        return Observable<Result<T, ApiError>>.create { [unowned self] observer in
            var task: URLSessionDataTask?
            
            if let urlReqeust = request.urlReqeust(baseURL: self.baseURL) {
                
                #if DEBUG
                    print("\n\n===== REQUEST ====== \n\n\(urlReqeust.url?.absoluteString ?? "")")
                #endif
                
                task = URLSession.shared.dataTask(with: urlReqeust) { data, response, error in
                    if let error = error {
                        let apiError: ApiError = .urlRequest(error)
                        observer.onNext(.failure(apiError))
                    } else if let data = data {
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
                    } else {
                        observer.onNext(.failure(.invalidRequest))
                    }
                    observer.onCompleted()
                }
                task?.resume()
            } else {
                observer.onNext(.failure(.invalidRequest))
                observer.onCompleted()
            }
        
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
//    func send<T>(apiRequest: APIRequest) -> Observable<T> {
//        return Observable<T>.create { [unowned self] observer in
//            let request = apiRequest.request(with: self.baseURL)
//            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                do {
//                    let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
//                    observer.onNext(model)
//                } catch let error {
//                    observer.onError(error)
//                }
//                observer.onCompleted()
//            }
//            task.resume()
//
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
}
