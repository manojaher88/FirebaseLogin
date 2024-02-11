//
//  LoginImplementer.swift
//  GymFitness
//
//  Created by Manoj Aher on 20/01/24.
//

import Foundation

// MARK: - LoginEngine
public protocol LoginService {
    func createAccount(email: String, password: String) async -> Result<AuthUser, LoginError>
    func updateUserDetails(forUserId uid: String, details: [String: AnyHashable]) async -> Bool

    func getLoggedInUser() async throws -> Result<AuthUser, LoginError>
    func signIn() async -> Result<AuthUser, LoginError>
    func signIn(email: String, password: String) async -> Result<AuthUser, LoginError>
    func logOut() throws
}

// MARK: - FirebaseLoginImp
public final class LoginImplementer: LoginService {
    private let loginEngine: LoginEngine
    public init(loginEngine: LoginEngine) {
        self.loginEngine = loginEngine
    }

    public func getLoggedInUser() async -> Result<AuthUser, LoginError> {
        await loginEngine.getLoggedInUser()
    }

    public func signIn() async -> Result<AuthUser, LoginError> {
        await loginEngine.signIn()
    }

    public func createAccount(email: String, password: String) async -> Result<AuthUser, LoginError> {
        await loginEngine.createAccount(email: email, password: password)
    }

    public func signIn(email: String, password: String) async -> Result<AuthUser, LoginError> {
        await loginEngine.signIn(email: email, password: password)
    }

    public func updateUserDetails(forUserId uid: String, details: [String: AnyHashable]) async -> Bool {
        await loginEngine.updateUserDetails(forUserId: uid, userDetails: details)
    }

    public func logOut() throws {
        try loginEngine.logOut()
    }
}
