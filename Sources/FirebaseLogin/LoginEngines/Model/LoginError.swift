//
//  LoginError.swift
//  GymFitness
//
//  Created by Manoj Aher on 04/02/24.
//

import Foundation

// MARK: - LoginError
public enum LoginError: Error {
    case accessDenied
    case tokenStringMissing
    case missingClientId
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case wrongPassword
    case networkError
    case corruptedData
    case loginNotSupported
    case unknownError(String)
}

// Extend LoginProviderError to provide error descriptions
extension LoginError: LocalizedError {
    public  var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access denied. Please try again."
        case .tokenStringMissing:
            return "Token string missing. Please try again."
        case .missingClientId:
            return "Missing client ID. Please try again."
        case .invalidEmail:
            return "The email address is invalid. Please enter a valid email address."
        case .emailAlreadyInUse:
            return "The email address is already in use. Please enter a different email address."
        case .weakPassword:
            return "The password is too weak. Please enter a stronger password."
        case .userNotFound:
            return "No user found with this email. Please make sure you've registered."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .corruptedData:
            return "Could not decode data into data model"
        case .loginNotSupported:
            return "Login not supported using email and password."
        case .unknownError(let localizedError):
            return localizedError
        }
    }
}
