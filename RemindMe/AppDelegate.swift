//
//  AppDelegate.swift
//  RemindMe
//
//  Created by vzyw on 1/31/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import WechatKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,JPUSHRegisterDelegate {
    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let  userInfo = notification.request.content.userInfo;
        if(notification.request.trigger is UNPushNotificationTrigger ) {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        else {
        }
        
        
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue));
    }

    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        print(1)
        
        let userInfo = response.notification.request.content.userInfo;
        if(response.notification.request.trigger is UNPushNotificationTrigger ) {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        else {
            print(1)
        }
        completionHandler();  // 系统要求执行这个方法
    }

    


    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Kit.setUserdefault(key: "friend", value: nil)
        Kit.setUserdefault(key: "wechatHead", value: nil)
        
        
//        JPUSH
        
        //通知类型（这里将声音、消息、提醒角标都给加上）
        let userSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound],categories: nil)
 

        if ((UIDevice.current.systemVersion as NSString).floatValue >= 8.0) {
            //可以添加自定义categories
            JPUSHService.register(forRemoteNotificationTypes: userSettings.types.rawValue,
                                  categories: nil)
        }
        else {
            //categories 必须为nil
            JPUSHService.register(forRemoteNotificationTypes: userSettings.types.rawValue,
                                  categories: nil)
        }
        
        // 启动JPushSDK
        JPUSHService.setup(withOption: nil, appKey: "23a9eaa8fddff3803a8e5100",
                           channel: "Publish Channel", apsForProduction: false)
//        JPUSH
        
        
        JPUSHService.registrationIDCompletionHandler { (code, rid) in
            if(code == 1011){return}
            Request().get(url: Config.registrationUrl, pram: ["rid":rid!], callback: nil)
        }
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //注册 DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //增加IOS 7的支持
        JPUSHService.handleRemoteNotification(userInfo)
        let message = userInfo["aps"] as! Dictionary<String,Any>
        self.noticeTop(message["alert"] as! String)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //可选
        NSLog("did Fail To Register For Remote Notifications With Error: \(error)")
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
        
        UIApplication.shared.applicationIconBadgeNumber = 0;
        JPUSHService.setBadge(0)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if(url.absoluteString.hasPrefix("remindme")){
            if(url.host != nil){
                Request().get(url: Config.publicUrl, pram: ["key":url.host!], callback: nil)
                return true
            }
            
        }
        return WechatManager.sharedInstance.handleOpenURL(url)
        
        
        // 如需要使用其他第三方可以 使用 || 连接 其他第三方库的handleOpenURL
        // return WechatManager.sharedInstance.handleOpenURL(url) || TencentOAuth.HandleOpenURL(url) || WeiboSDK.handleOpenURL(url, delegate: SinaWeiboManager.sharedInstance) ......
    }
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
//        //加入跳转代码
//        
//        print(1)
//    }
    
    

}

