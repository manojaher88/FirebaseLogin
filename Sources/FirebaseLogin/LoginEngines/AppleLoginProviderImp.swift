//
//  ProviderLogin.swift
//  GymFitness
//
//  Created by Manoj Aher on 26/01/24.
//

import Foundation
import AuthenticationServices
import CryptoKit

// MARK: - AppleLoginProviderImp
final class AppleLoginProviderImp: NSObject, LoginProvider {
    func login<T>(email: String, password: String) async -> Result<T, LoginError> where T : Decodable {
        .failure(.loginNotSupported)
    }
    
    private var currentNonce: String?
    private var completion: ((Result<LoginCredential, LoginError>) -> Void)?

    func login() async -> Result<LoginCredential, LoginError> {
        do {
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let self else { return }
                loginWithApple { [weak self] result in
                    self?.completion = nil
                    continuation.resume(returning: result)
                }
            }
        } catch {
            completion = nil
            return .failure(.unknownError("Failed to login with Apple"))
        }
    }

    private func loginWithApple(completion: @escaping(Result<LoginCredential, LoginError>) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        self.completion = completion
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - AppleLoginProviderImp
private extension AppleLoginProviderImp {
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleLoginProviderImp: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                completion?(.failure(.unknownError("Invalid state: A login callback was received, but no login request was sent.")))
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                completion?(.failure(.unknownError("Unable to fetch identity token")))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                completion?(.failure(.unknownError("Unable to serialize token string from data: \(appleIDToken.debugDescription)")))
                return
            }

            // Initialize a Firebase credential, including the user's full name.
            let credential = LoginCredential(provider: .apple, idTokenString: idTokenString, accessToken: "",
                                             nonce: nonce, fullName: appleIDCredential.fullName)
            completion?(.success(credential))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        completion?(.failure(.unknownError(error.localizedDescription)))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleLoginProviderImp: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
