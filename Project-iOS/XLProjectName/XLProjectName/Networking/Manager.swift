//
//  Manager.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess
import RxSwift

class NetworkManager: RxManager {

    static let singleton = NetworkManager(manager: SessionManager.default)

    override init(manager: Alamofire.SessionManager) {
        super.init(manager: manager)
        observers = [Logger() as ObserverType]
    }
}

final class Route {}

struct Logger: ObserverType {
    func willSendRequest(_ alamoRequest: Alamofire.Request, requestConvertible: URLRequestConvertible) {
        debugPrint(alamoRequest)
    }
}
