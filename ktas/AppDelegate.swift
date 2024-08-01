//
//  AppDelegate.swift
//  ktas
//
//  Created by JinGu's iMac on 2020/07/07.
//  Copyright © 2020 JinGu's iMac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    var loginVC : LoginViewController?
    var mainVC : ViewController?
    var naviCon : UINavigationController?
    var mv : ViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Crashlytics.crashlytics().setUserID(deviceID)
        
        NetworkManager.shared.startNetworkReachabilityObserver()
        
        window = UIWindow(frame: SCREEN.BOUND)
        
        addKeyboardObserver()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        mv = ViewController()
        mainVC = ViewController()
        loginVC = LoginViewController()
        naviCon = UINavigationController(rootViewController: loginVC!)
        
        naviCon?.isNavigationBarHidden = true
        window?.rootViewController = naviCon!
       
        return true
    }
    
    var isActive = false
    lazy var blackView : UIView = {
        let kBlackView = UIView(frame: SCREEN.BOUND)
        kBlackView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        appDel.window?.addSubview(kBlackView)
        kBlackView.isHidden = true
        return kBlackView
    }()

    lazy var recodingBlackView : UIView = {
        let kBlackView = UIView(frame: SCREEN.BOUND)
        kBlackView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        appDel.window?.addSubview(kBlackView)
        kBlackView.isHidden = true
        return kBlackView
    }()
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.isActive = true
        self.blackView.isHidden = true
        
        Server.sendLog(state: "applicationDidBecomeActive")
//        sleep(1)
    }

    func applicationWillResignActive(_ application: UIApplication) {
    
        self.isActive = false
        self.blackView.isHidden = false
        
        Server.sendLog(state: "applicationWillResignActive")
        sleep(1)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Server.sendLog(state: "applicationWillEnterForeground")
//        sleep(1)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        Server.sendLog(state: "applicationDidEnterBackground")
        sleep(1)
        
    }
    

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        Server.sendLog(state: "applicationDidReceiveMemoryWarning")
        sleep(3)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Server.sendLog(state: "applicationWillTerminate")
        sleep(3)
    }
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("handleEventsForBackgroundURLSession")
        backgroundSessionCompletionHandler = completionHandler
    }
    

}

