//
//  AppDelegate.swift
//  iCurrency
//
//  Created by Armands Baurovskis on 27/04/2019.
//  Copyright © 2019 iOSCoder. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    #if DEBUG
      guard Constants.Tests.isUnitTesting() == false else { return false }
    #endif
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    let rootViewController = UINavigationController(rootViewController: CurrencyViewController())
    self.window?.rootViewController = rootViewController
    self.window?.makeKeyAndVisible()
    return true
  }
}

