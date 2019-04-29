//
//  Data+JSON.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 29/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import Foundation

extension Data {
  static func json(bundle: Bundle = Bundle.main, fileName: String) -> Data? {
    return self.file(bundle: bundle, fileName: fileName, extension: "json")
  }

  static func file(bundle: Bundle = Bundle.main, fileName: String, extension: String) -> Data? {
    guard let fileUrl = bundle.url(forResource: fileName, withExtension: `extension`) else {
      return nil
    }

    let data = try? Data(contentsOf: fileUrl)
    return data
  }
}
