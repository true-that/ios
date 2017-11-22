//
//  AppDelegate.swift
//  TrueThat
//
//  Created by Ohad Navon on 09/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import Appsee
import Fabric
import Crashlytics
import SendBirdSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var receivedPushChannelUrl: String?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    App.log.debug("Application loaded")
    // Register notifications
    let center  = UNUserNotificationCenter.current()
    center.delegate = self
    center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in}
    application.registerForRemoteNotifications()
    // Override point for customization after application launch.
    #if DEBUG
      let configuration = URLSessionConfiguration.default
      configuration.timeoutIntervalForRequest = 1
      configuration.timeoutIntervalForResource = 10
      configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
      _ = Alamofire.SessionManager(configuration: configuration)
      SBDMain.setLogLevel(SBDLogLevel.info)
    #else
      SBDMain.setLogLevel(SBDLogLevel.error)
    #endif

    // Fabric tools
    Fabric.with([Crashlytics.self, Appsee.self])

    // Init SendBird
    SBDMain.initWithApplicationId("5A2C83D8-3C58-47CE-B31A-ED758808A79F")
    SBDOptions.setUseMemberAsMessageSender(true)

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of
    // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should
    // use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application
    // state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate:
    // when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes
    // made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application
    // was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate.
    // See also applicationDidEnterBackground:.
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    SBDMain.registerDevicePushToken(deviceToken, unique: true) { (status, error) in
      if error == nil {
        if status == SBDPushTokenRegistrationStatus.pending {

        }
        else {

        }
      }
      else {

      }
    }
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    if userInfo["sendbird"] != nil {
      let sendBirdPayload = userInfo["sendbird"] as! Dictionary<String, Any>
      let channel = (sendBirdPayload["channel"]  as! Dictionary<String, Any>)["channel_url"] as! String
      let channelType = sendBirdPayload["channel_type"] as! String
      if channelType == "group_messaging" {
        self.receivedPushChannelUrl = channel
      }
    }
  }
}

// MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let sendBirdInfo = response.notification.request.content.userInfo["sendbird"]
    if sendBirdInfo != nil {
      let sendBirdPayload = sendBirdInfo as! Dictionary<String, Any>
      let channel = (sendBirdPayload["channel"]  as! Dictionary<String, Any>)["channel_url"] as! String
      let channelType = sendBirdPayload["channel_type"] as! String
      if channelType == "group_messaging" {
        self.receivedPushChannelUrl = channel
      }
    }
  }
}
