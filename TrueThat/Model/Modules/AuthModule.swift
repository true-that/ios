//
//  AuthModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Manages authentication and autherization for the application.
class AuthModule {
  /// Keychain user session key
  static let userKey = "LAST_USER_SESSION"
  
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
  public func signUp(fullName: String) {
    App.log.verbose("They all sign up eventually")
    let toAuth = User(id: nil, firstName: StringHelper.extractFirstName(of: fullName),
                      lastName: StringHelper.extractLastName(of: fullName),
                      deviceId: App.deviceModule.deviceId!)
    authRequest(for: toAuth)
  }
  
  /// User initiated auth attempt.
  public func signIn() {
    App.log.verbose("Hmmm.. have we met?")
    var toSignIn = lastSession
    if toSignIn == nil {
      toSignIn = User(id: nil, firstName: nil, lastName: nil, deviceId: App.deviceModule.deviceId)
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
    App.log.verbose("Trying to auth..")
    // Checking if already logged in
    if current != nil && current!.isAuthOk {
      App.log.verbose("its \(current!.displayName) again!")
      delegate?.didAuthOk()
      return
    }
    // Trying to restore last session
    if lastSession != nil {
      App.log.verbose("Restored session: \(String(describing: lastSession!.displayName)) seems kind of familiar..")
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
    _ = AuthApi.auth(for: user)
      .on(value: {
        if $0.isAuthOk {
          self.current = $0
          App.log.verbose("Auth OK: we missed ya \(self.current!.displayName) already!")
          do {
            try App.keychainModule.save(JSON(from: self.current!).rawData(), key: AuthModule.userKey)
          } catch {
            App.log.warning("Could not save user session to keychain.")
          }
          self.delegate?.didAuthOk()
        } else {
          App.log.warning("Responsed user is not auth OK: \($0)")
          self.current = nil
          self.delegate?.didAuthFail()
        }
      })
      .on(failed: { error in
        App.log.error("Failed auth request for \(user), with error \(error)")
        self.current = nil
        self.delegate?.didAuthFail()
      })
      .start()
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
