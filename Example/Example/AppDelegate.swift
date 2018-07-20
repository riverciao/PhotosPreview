//
//  AppDelegate.swift
//  Example
//
//  Created by riverciao on 2018/7/20.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let previewController = PreviewController()
        window?.rootViewController = previewController
        
        return true
    }
}

