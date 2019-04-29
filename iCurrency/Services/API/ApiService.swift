//
//  ApiService.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation

protocol ApiService {
  var service: ApiClient { get }
  func setEnvironment(environment: ApiClient.Environment)
  func setPredefiniedResponse(data: [Data])
}

extension ApiService {

  func setEnvironment(environment: ApiClient.Environment) {
    self.service.environment = environment
  }

  func setPredefiniedResponse(data: [Data]) {
    guard self.service.environment == .test else { return }
    self.service.predefiniedResponse = data
  }
}
