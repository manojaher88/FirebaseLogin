//
//  LoginProvider.swift
//  GymFitness
//
//  Created by Manoj Aher on 04/02/24.
//

import Foundation
import FirebaseAuth

protocol LoginProvider {
    func login() async -> Result<LoginCredential, LoginError>
    func login<T: Decodable>(email: String, password: String) async -> Result<T, LoginError>
}
