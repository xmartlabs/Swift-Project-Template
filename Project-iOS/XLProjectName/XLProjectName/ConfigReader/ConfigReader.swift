//
//  ConfigReader.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/27/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation

typealias LogInCharactersLimit = (minUsernameLength: Int, minPasswordLength: Int)
typealias PrivacyLinks = (termsOfUse: String, privacyPolicy: String)
typealias DeepLinkData = (hosts: [String], resetPasswordPath: String, shareProfilePath: String)

enum UsersResourceKey {
    case userProfile
}

struct APIServiceConfiguration {
    let baseURL: String
    
    let isDebugLog: Bool
}

/// Configuration reader
class ConfigReader {
    fileprivate var properties = [String: AnyObject]()
    
    init(withPath path: String) {
        guard let plistProperties = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            assertionFailure("Could not read config plist")
            return
        }
        properties = plistProperties
    }
    
    convenience init(withConfigName configName: String) {
        guard let path = Bundle.main.path(forResource: configName, ofType: "plist") else {
            assertionFailure("Could not read path for config plist")
            self.init(withPath: "")
            
            return
        }
        self.init(withPath: path)
    }
    
    convenience init() {
        let configKey = "Config"
        guard let configName = Bundle.main.object(forInfoDictionaryKey: configKey) as? String else {
            assertionFailure("Could not find config plist")
            self.init(withConfigName: "")
            
            return
        }
        self.init(withConfigName: configName)
    }
    
    // MARK: - Application configuration
    var isDebug: Bool {
        return readValue(forPath: ["Debug"]) ?? true
    }
    
    var isTest: Bool {
        return readValue(forPath: ["Test"]) ?? false
    }
    
    var isAppStore: Bool {
        return readValue(forPath: ["AppStore"]) ?? true
    }
    
    // MARK: - Instabug
    var instabugToken: String {
        return readValue(forPath: ["Instabug", "Token"]) ?? ""
    }
    
    // MARK: - Networking
    var apiService: APIServiceConfiguration {
        return apiServiceConfiguration
    }
    
    // MARK: - Privacy
    var privacyLinks: PrivacyLinks {
        let termsOfUse = readValue(forPath: ["Privacy", "TermsOfUse"]) ?? ""
        let privacyPolicy = readValue(forPath: ["Privacy", "PrivacyPolicy"]) ?? ""
        
        return (termsOfUse, privacyPolicy)
    }
    
    // MARK: - Log In
    var logInCharactersLimit: LogInCharactersLimit {
        let minUsername: Int = readValue(forPath: ["LogIn", "MinUsernameLength"]) ?? 3
        let minPassword: Int = readValue(forPath: ["LogIn", "MinPasswordLength"]) ?? 6
        
        return (minUsername, minPassword)
    }
    
    // MARK: - App store Rating
    var appStoreId: String {
        return readValue(forPath: ["Rating", "AppStoreId"]) ?? ""
    }
    
    // MARK: - Deep Link
    var deepLinkData: DeepLinkData {
        return (hosts: readValue(forPath: ["DeepLink", "Hosts"]) ?? [],
                resetPasswordPath: readValue(forPath: ["DeepLink", "ResetPasswordPath"]) ?? "",
                shareProfilePath: readValue(forPath: ["DeepLink", "ShareProfilePath"]) ?? ""
        )
    }
}

// MARK: - Networking
private extension ConfigReader {
    var apiServiceConfiguration: APIServiceConfiguration {
        return APIServiceConfiguration(baseURL: readValue(forPath: ["Network", "Server", "BaseURL"]) ?? "",
                                           isDebugLog: isDebug)
    }
    
}

// MARK: - Generic for reading values
extension ConfigReader {
    func readValue<T>(forPath path: [String]) -> T? {
        var path = path
        guard let valueKey = path.popLast() else {
            return nil
        }
        
        var dictionary: [String: AnyObject]? = properties
        for pathElement in path {
            dictionary = dictionary?[pathElement] as? [String: AnyObject]
        }
        
        return dictionary?[valueKey] as? T
    }
    
    func readNetworkConfig(forKey key: String, in path: String) -> String {
        return readNetworkConfig(forKey: key, in: [path])
    }
    
    func readNetworkConfig(forKey key: String, in paths: [String]) -> String {
        return readValue(forPath: ["Network", "Server"] + paths + [key]) ?? ""
    }
}


