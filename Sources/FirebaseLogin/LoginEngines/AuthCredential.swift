//
//  AuthCredential.swift
//  GymFitness
//
//  Created by Manoj Aher on 04/02/24.
//

import Foundation

public enum Provider: String, Decodable {
    case apple = "Apple"
    case google = "Google"
    case password = "Password"
}

struct LoginCredential {
    let provider: Provider
    let idTokenString: String
    let accessToken: String
    let nonce: String
    let fullName: PersonNameComponents?
}

struct AppleCredentials {
    let idTokenString: String
    let nonce: String
}
