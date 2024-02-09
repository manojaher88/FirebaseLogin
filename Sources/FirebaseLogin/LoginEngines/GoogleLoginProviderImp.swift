//
//  GoogleLoginProviderImp.swift
//  GymFitness
//
//  Created by Manoj Aher on 26/01/24.
//

import Firebase
import GoogleSignIn

// MARK: - GoogleLoginProviderImp
final class GoogleLoginProviderImp: LoginProvider {
    // MARK: - login with google
    func login() async -> Result<LoginCredential, LoginError> {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return .failure(.missingClientId)
        }
        return await getCredential(clientID: clientID)
    }
    
    @MainActor
    private func getCredential(clientID: String) async -> Result<LoginCredential, LoginError> {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: getController())
            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                return .failure(.tokenStringMissing)
            }
            let cred = LoginCredential(provider: .google, idTokenString: idToken,
                                       accessToken: user.accessToken.tokenString,
                                       nonce: "", fullName: nil)
            return .success(cred)
        } catch {
            print(error)
            if let error = error as? GIDSignInError,
               error.code == GIDSignInError.canceled {
                return .failure(.accessDenied)
            }
            return .failure(.unknownError(error.localizedDescription))
        }
    }
    
    @MainActor
    private func getController() -> UIViewController {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)!.windows }
            .last!.rootViewController!
    }
}

// MARK: - login with emailId and password
extension GoogleLoginProviderImp {
    func login<T: Decodable>(email: String, password: String) async -> Result<T, LoginError> {
        // Check if the email is valid
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let providerId = authDataResult.user.providerID
            guard let data = providerId.data(using: .utf8) else {
                return .failure(.corruptedData)
            }
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                return .success(model)
            } catch {
                return .failure(.corruptedData)
            }
        } catch {
            let authError = AuthErrorCode(_nsError: error as NSError)
            switch authError.code {
            case .userNotFound:
                return .failure(.userNotFound)
            case .wrongPassword:
                return .failure(.wrongPassword)
            case .networkError:
                return .failure(.networkError)
            default:
                return .failure(.unknownError(error.localizedDescription))
            }
        }
    }
}

// MARK: - Private utility methods
extension GoogleLoginProviderImp {
    private func isValidEmail(_ email: String) -> Bool {
        // Regex to validate the email (basic validation)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
