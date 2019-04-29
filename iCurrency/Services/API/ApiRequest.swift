//
//  ApiRequest.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
  case GET
  case POST
}

struct ApiRequest {
  let method: HTTPMethod
  let endpoint: String
  var headers: [String: String]?
  var parameters: [String: String]?

  init(method: HTTPMethod,
       endpoint: String,
       headers: [String: String]? = nil,
       parameters: [String: String]? = nil) {

    self.method = method
    self.endpoint = endpoint
    self.headers = headers
    self.parameters = parameters
  }
}

extension ApiRequest {

  func urlReqeust(baseURL: URL) -> URLRequest? {
    guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint),
                                         resolvingAgainstBaseURL: false) else {
                                          return nil
    }

    components.queryItems = parameters?.map {
      URLQueryItem(name: String($0), value: String($1))
    }

    guard let url = components.url else {
      return nil
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request
  }
}
