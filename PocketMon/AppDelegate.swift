//
//  AppDelegate.swift
//  PocketMon
//
//  Created by t2023-m0102 on 8/6/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var window: UIWindow?
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: MainViewController())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
