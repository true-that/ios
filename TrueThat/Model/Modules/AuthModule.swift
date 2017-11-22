//
//  AuthModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Crashlytics
import SwiftyJSON
import SendBirdSDK

/// Manages authentication and autherization for the application.
class AuthModule {
  /// Keychain user session key
  static let userKey = "last_user_session"

  /// User defaults user id
  static let userDefaultsUserId = "user_id"

  /// User defaults nickname
  static let userDefaultsNickname = "nickname"

  public var delegate: AuthDelegate?

  /// Current authenticated user.
  public var current: User?

  /// Whether the current user is authenticated.
  public var isAuthOk: Bool {
    if current != nil {
      return current!.isAuthOk
    }
    return false
  }

  // MARK: Actions

  /// Signs up a new user and registers it on our backend.
  ///
  /// - Parameter fullName: of new user
  /// - Parameter phoneNumber: of the user's device. expected to be prettified.
  public func signUp(fullName: String, phoneNumber: String) {
    App.log.debug("They all sign up eventually")
    let toAuth = User(id: nil, firstName: StringHelper.extractFirstName(of: fullName),
                      lastName: StringHelper.extractLastName(of: fullName),
                      deviceId: App.deviceModule.deviceId,
                      phoneNumber: phoneNumber)
    authRequest(for: toAuth)
  }

  /// User initiated auth attempt.
  public func signIn() {
    App.log.debug("Hmmm.. have we met?")
    if isAuthOk {
      App.log.debug("it appears so!")
      delegate?.didAuthOk()
      return
    }
    var toSignIn = lastSession
    if toSignIn == nil {
      toSignIn = User(id: nil, firstName: nil, lastName: nil, deviceId: App.deviceModule.deviceId, phoneNumber: nil)
    }
    if toSignIn != nil {
      authRequest(for: toSignIn!)
    } else {
      current = nil
      delegate?.didAuthFail()
    }
  }

  /// Authenticates a user based on user session.
  public func auth() {
    App.log.debug("Trying to auth..")
    // Checking if already logged in
    if current != nil && current!.isAuthOk {
      App.log.debug("its \(current!.displayName) again!")
      delegate?.didAuthOk()
      return
    }
    // Trying to restore last session
    if lastSession != nil {
      App.log.debug("Restored session: \(String(describing: lastSession!.displayName)) seems kind of familiar..")
      authRequest(for: lastSession!)
      return
    }
    current = nil
    delegate?.didAuthFail()
  }

  /// Signs the current user out and deletes existing session.
  public func signOut() {
    App.log.verbose("see ya")
    current = nil
    do {
      try App.keychainModule.delete(AuthModule.userKey)
    } catch {
      App.log.warning("Could not delete user session from keychain.")
    }
    delegate?.didAuthFail()
  }

  func authRequest(for user: User) {
    Crashlytics.sharedInstance().setObjectValue(
      user, forKey: LoggingKey.authUser.rawValue.snakeCased()!.uppercased())
    SBDMain.connect(withUserId: user.phoneNumber!, completionHandler: { (sendBirdUser, connectError) in
      if connectError != nil {
        self.delegate?.didAuthFail()
        return
      }
      if SBDMain.getPendingPushToken() != nil {
        SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, unique: true, completionHandler: { (status, statusError) in
          if statusError == nil {
            if status == SBDPushTokenRegistrationStatus.pending {
              App.log.verbose("Push registeration is pending.")
            } else {
              App.log.info("APNS Token is registered.")
            }
          } else {
            App.log.warning("APNS registration failed.")
          }
        })
      }

      SBDMain.updateCurrentUserInfo(
        withNickname: user.displayName, profileUrl: nil, completionHandler: { updateError in
          if updateError != nil {
            App.log.report("Failed to update nickname.", withError: updateError!)
            SBDMain.disconnect(completionHandler: {})
            self.delegate?.didAuthFail()
            return
          }
          App.log.debug("Auth OK: we missed ya \(self.current!.displayName) already!")
          do {
            try App.keychainModule.save(JSON(from: self.current!).rawData(), key: AuthModule.userKey)
          } catch {
            App.log.warning("Could not save user session to keychain.")
          }
          Crashlytics.sharedInstance().setUserIdentifier(String(describing: self.current!.id!))
          Crashlytics.sharedInstance().setUserName(self.current!.displayName)
          self.delegate?.didAuthOk()
      })
    })
  }

  fileprivate var lastSession: User? {
    let lastSession = App.keychainModule.get(AuthModule.userKey)
    if lastSession != nil {
      return User(json: JSON(lastSession!))
    }
    return nil
  }
}

protocol AuthDelegate {

  /// Authentication successful callback.
  func didAuthOk()

  /// Authentication failure callback.
  func didAuthFail()
}
