//
//  Configure.swift
//  GymFitness
//
//  Created by Manoj Aher on 16/01/24.
//

import Foundation
import Firebase

public class Configure {
    public class func start() {
        FirebaseApp.configure()
//        Auth.auth().useEmulator(withHost:"127.0.0.1", port:9099)
//        let settings = Firestore.firestore().settings
//        settings.host = "127.0.0.1:8080"
//        settings.cacheSettings = MemoryCacheSettings()
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
    }
}
