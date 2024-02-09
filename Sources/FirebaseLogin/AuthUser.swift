//
//  AuthUser.swift
//  GymFitness
//
//  Created by Manoj Aher on 03/02/24.
//

import Foundation

// MARK: - AuthUser
public struct AuthUser: Decodable {
    public init(userId: String, emailId: String, refreshToken: String,
         newUser: Bool, provider: Provider,
         createdDate: Date?, signedInDate: Date?) {
        self.id = userId
        self.emailId = emailId
        self.refreshToken = refreshToken
        self.newUser = newUser
        self.provider = provider
        self.createdDate = createdDate
        self.signedInDate = signedInDate
    }
    public let id: String
    public let emailId: String
    public let refreshToken: String
    public let newUser: Bool
    public let provider: Provider
    public let createdDate: Date?
    public let signedInDate: Date?
}
