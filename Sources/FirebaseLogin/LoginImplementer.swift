//
//  LoginImplementer.swift
//  GymFitness
//
//  Created by Manoj Aher on 20/01/24.
//

import Foundation

// MARK: - LoginEngine
public protocol LoginService: AnyObject {
    func login(email: String, password: String) async -> Result<AuthUser, LoginError>
    func createAccount(email: String, password: String) async -> Result<AuthUser, LoginError>
    func updateUserDetails(forUserId uid: String, details: [String: AnyHashable]) async -> Bool
    func signInWithApple() async -> Result<AuthUser, LoginError>
    func signInWithGoogle() async -> Result<AuthUser, LoginError>
}

// MARK: - FirebaseLoginImp
public final class LoginImplementer: LoginService {
    private let loginEngine: LoginEngine
    public init(loginEngine: LoginEngine) {
        self.loginEngine = loginEngine
    }

    public func login(email: String, password: String) async -> Result<AuthUser, LoginError> {
        await loginEngine.login(email: email, password: password)
    }

    public func createAccount(email: String, password: String) async -> Result<AuthUser, LoginError> {
        await loginEngine.createAccount(email: email, password: password)
    }

    public func updateUserDetails(forUserId uid: String, details: [String: AnyHashable]) async -> Bool {
        await loginEngine.updateUserDetails(forUserId: uid, userDetails: details)
    }

    public func signInWithApple() async -> Result<AuthUser, LoginError> {
        await loginEngine.signInWithApple()
    }

    public func signInWithGoogle() async -> Result<AuthUser, LoginError> {
        await loginEngine.signInWithGoogle()
    }
}
