//
//  File.swift
//  
//
//  Created by Manoj Aher on 11/02/24.
//

import Foundation
import FirebaseAuth

// MARK: - AuthManoj
public protocol LoginAuth {
    var currentUser: User? { get }
    static func auth() -> Auth

    func removeStateDidChangeListener(_ listenerHandle: AuthStateDidChangeListenerHandle)
    func addStateDidChangeListener(_ listener: @escaping (Auth, User?) -> Void) -> AuthStateDidChangeListenerHandle
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult
    func signIn(with credential: AuthCredential) async throws -> AuthDataResult
    func signOut() throws
}

extension Auth: LoginAuth { }

// MARK: - User
extension User {
    var providerType: Provider {
        switch providerID {
        case "password":
            return .password
        case "google.com":
            return .google
        case "apple.com":
            return .apple
        default:
            return .unknown
        }
    }
}
