//
//  AppDelegate.swift
//  SearchSpotify
//
//  Created by Himanshi Bhardwaj on 8/17/17.
//  Copyright © 2017 Himanshi Bhardwaj. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var auth = SPTAuth()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        customizeNavigationBar()
        
        auth.redirectURL     = URL(string: SearchSpotifyData.redirectURIs) // insert your redirect URL here
        auth.sessionUserDefaultsKey = SearchSpotifyData.sessionUserDefaultsKey
        
        // Refresh token if needed
        if let searchApi = SpotifySearchApi.current {
            if let session = searchApi.session {
                if !session.isValid() {
                    searchApi.refreshToken()
                }
            }
        }
        
        return true
    }
    
    func customizeNavigationBar() {
        // Customize navigation bar
        let navAppearance = UINavigationBar.appearance()
        
        //To make navbar translucent
        navAppearance.setBackgroundImage(UIImage(), for: .default)
        navAppearance.shadowImage = UIImage()
        
        //To make barbutton and baritem text white
        navAppearance.tintColor = .white
        navAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    /**
     Called when user signs into spotify.
     Session data saved into user defaults, then notification posted to call
     Modeled off recommended auth flow suggested by Spotify documentation
     **/
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // 1 - check if app can handle redirect URL
        if auth.canHandle(auth.redirectURL) {
            // 2 - handle callback in closure
            auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                // 3 - handle error
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                // 4 - Add session to User Defaults
                let userDefaults = UserDefaults.standard
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                // 5 - Set current user
                SpotifySearchApi.current?.session = session
                SpotifySearchApi.current?.createUser()
                // 6 - Tell notification center login is successful
                NotificationCenter.default.post(name: Notification.Name(rawValue: "signInSuccessful"), object: nil)
            })
            return true
        }
        return false
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

