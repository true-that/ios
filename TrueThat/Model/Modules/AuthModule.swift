//
//  AuthModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 27/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

/// Manages authentication and autherization for the application.
class AuthModule {
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
  
  /// Signs up a new user and registers it on our backend.
  ///
  /// - Parameter fullName: of new user
  public func signUp(fullName: String) {
    App.log.verbose("signUp: They all sign up eventually")
    let toAuth = User(id: nil, firstName: StringHelper.extractFirstName(of: fullName),
                      lastName: StringHelper.extractLastName(of: fullName),
                      deviceId: App.deviceModule.deviceId!)
    _ = AuthApi.auth(for: toAuth)
      .on(value: {
        if $0.isAuthOk {
          self.current = $0
          self.saveSession()
          self.delegate?.didAuthOk()
        } else {
          self.delegate?.didAuthFail()
        }
      })
      .on(failed: { error in
        App.log.error("Failed auth request: \(error)")
        self.delegate?.didAuthFail()
      })
      .start()
  }
  
  // MARK: Actions
  public func signIn() {
    App.log.verbose("signIn: And...he's back!")
    auth()
  }
  
  /// Authenticates a user based on user session.
  public func auth() {
    App.log.verbose("auth: it's \(String(describing: current?.displayName)) again")
    // Checking if already logged in
    if current != nil && current!.isAuthOk {
      delegate?.didAuthOk()
      return
    }
    // Trying to restore last session
    let lastSession = restoreSession()
    if lastSession != nil && lastSession!.isAuthOk {
      current = lastSession!
      delegate?.didAuthOk()
      return
    }
    delegate?.didAuthFail()
  }
  
  /// Signs the current user out and deletes existing session.
  public func signOut() {
    App.log.verbose("signOut: see you soon")
    current = nil
    deleteSavedSession()
    delegate?.didAuthFail()
  }
  
  /// Attempts to read user session from previous application usage, and use it to authenticate.
  ///
  /// - Returns: Last user session.
  func restoreSession() -> User? {
    return nil
  }
  
  /// Saves current user for future authentication.
  func saveSession() {
  }
  
  /// Deletes current user session, so that future authentication will not be able to use it.
  func deleteSavedSession() {
    
  }
}

protocol AuthDelegate {
  
  /// Authentication successful callback.
  func didAuthOk()
  
  /// Authentication failure callback.
  func didAuthFail()
}
