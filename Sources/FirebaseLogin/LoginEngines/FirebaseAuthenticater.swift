//
//  FirebaseAuthenticater.swift
//  GymFitness
//
//  Created by Manoj Aher on 14/01/24.
//

import Foundation
import FirebaseAuth

// MARK: - LoginEngine
public protocol LoginEngine: AnyObject {
    func getLoggedInUser() async -> Result<AuthUser, LoginError>
    func signIn() async -> Result<AuthUser, LoginError>
    func signIn(email: String, password: String) async -> Result<AuthUser, LoginError>
    func createAccount(email: String, password: String) async -> Result<AuthUser, LoginError>
    func updateUserDetails(forUserId uid: String, userDetails: [String: AnyHashable]) async -> Bool
    func logOut() throws
}

// MARK: - FirebaseLoginImp
public final class FirebaseLoginImp: LoginEngine {
    private var handler: AuthStateDidChangeListenerHandle?
    private var stateListener: AuthStateDidChangeListenerHandle?
    private let loginProvider: LoginProvider

    private var loggedInUser: User? {
        Auth.auth().currentUser
    }

    public init(loginProvider: LoginProvider) {
        self.loginProvider = loginProvider
        setupObservations()
    }

    deinit {
        guard let stateListener = stateListener else { return }
        Auth.auth().removeStateDidChangeListener(stateListener)
    }

    private func setupObservations() {
        stateListener = Auth.auth().addStateDidChangeListener { auth, user in
            print(auth)
            print(user ?? "No User found")
        }
    }
}

// MARK: - Reterive LoggedIn User
extension FirebaseLoginImp {
    public func getLoggedInUser() async -> Result<AuthUser, LoginError> {
        guard let user = loggedInUser else {
            return .failure(.userNotFound)
        }
        do {
            try await user.reload()
            let model = AuthUser(userId: user.uid, emailId: user.email ?? "",
                                 refreshToken: user.refreshToken ?? "",
                                 newUser: false,
                                 provider: user.providerType,
                                 createdDate: user.metadata.creationDate,
                                 signedInDate: user.metadata.lastSignInDate)
            return .success(model)
        } catch {
            return .failure(.userNotFound)
        }
    }
}

// MARK: - Create account
extension FirebaseLoginImp {
    public func createAccount(email: String, password: String) async -> Result<AuthUser, LoginError> {
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        guard !password.isEmpty else {
            return .failure(.weakPassword)
        }

        do {
            let dataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            if dataResult.user.isEmailVerified == false {
                try await dataResult.user.sendEmailVerification()
            }
            let model = AuthUser(userId: dataResult.user.uid, emailId: dataResult.user.email ?? email,
                                 refreshToken: dataResult.user.refreshToken ?? "",
                                 newUser: dataResult.additionalUserInfo?.isNewUser ?? false,
                                 provider: .password,
                                 createdDate: dataResult.user.metadata.creationDate,
                                 signedInDate: dataResult.user.metadata.lastSignInDate)
            return .success(model)
        } catch {
            let newEmailError = AuthErrorCode(_nsError: error as NSError)
            switch newEmailError.code {
            case .emailAlreadyInUse:
                return .failure(.emailAlreadyInUse)
            case .weakPassword:
                return .failure(.weakPassword)
            default:
                return .failure(.unknownError(error.localizedDescription))
            }
        }
    }

    private func signIn(with authCred: LoginCredential) async -> Result<AuthUser, LoginError> {
        do {
            var cred: AuthCredential
            switch authCred.provider {
            case .apple:
                cred = OAuthProvider.appleCredential(withIDToken: authCred.idTokenString,
                                                     rawNonce: authCred.nonce,
                                                     fullName: authCred.fullName)
            case .google:
                cred = GoogleAuthProvider.credential(withIDToken: authCred.idTokenString,
                                                     accessToken: authCred.accessToken)
            case .password, .unknown:
                return .failure(.loginNotSupported)
            }
            let dataResult = try await Auth.auth().signIn(with: cred)
            let model = AuthUser(userId: dataResult.user.uid, emailId: dataResult.user.email ?? "",
                                 refreshToken: dataResult.user.refreshToken ?? "",
                                 newUser: dataResult.additionalUserInfo?.isNewUser ?? false,
                                 provider: authCred.provider,
                                 createdDate: dataResult.user.metadata.creationDate,
                                 signedInDate: dataResult.user.metadata.lastSignInDate)
            return .success(model)
        } catch {
            print(error)
            let newEmailError = AuthErrorCode(_nsError: error as NSError)
            switch newEmailError.code {
            case .emailAlreadyInUse:
                return .failure(.emailAlreadyInUse)
            case .weakPassword:
                return .failure(.weakPassword)
            default:
                return .failure(.unknownError(error.localizedDescription))
            }
        }
    }
}

// MARK: - Private utility methods
extension FirebaseLoginImp {
    private func isValidEmail(_ email: String) -> Bool {
        // Regex to validate the email (basic validation)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// MARK: - Update user details
extension FirebaseLoginImp {
    // TODO: - Move this to different class
    public func updateUserDetails(forUserId uid: String, userDetails: [String: AnyHashable]) async -> Bool {
        //        let firestore = Firestore.firestore()
        //        do {
        //            try await firestore.collection("user").document(uid).setData(userDetails, merge: true)
        //            return true
        //        } catch {
        //            return false
        //        }
        false
    }
}

// MARK: - Available Login methods
extension FirebaseLoginImp {
    public func signIn(email: String, password: String) async -> Result<AuthUser, LoginError> {
        let imp = GoogleLoginProviderImp()
        let result: Result<AuthUser, LoginError> = await imp.login(email: email, password: password)
        return result
    }
}

// MARK: - SignIn
extension FirebaseLoginImp {
    public func signIn() async -> Result<AuthUser, LoginError> {
        let result = await loginProvider.login()
        switch result {
        case .success(let cred):
            return await signIn(with: cred)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - logOut
extension FirebaseLoginImp {
    public func logOut() throws {
        try Auth.auth().signOut()
    }
}
