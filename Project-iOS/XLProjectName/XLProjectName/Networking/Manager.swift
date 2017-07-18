//
//  Manager.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import OperaSwift
import Alamofire
import KeychainAccess
import RxSwift

class NetworkManager: RxManager {

    static let singleton = NetworkManager(manager: SessionManager.default)

    override init(manager: Alamofire.SessionManager) {
        super.init(manager: manager)
        observers = [Logger() as OperaSwift.ObserverType]
    }

    override func response(_ requestConvertible: URLRequestConvertible) -> PrimitiveSequence<SingleTrait, OperaResult> {
        let response = super.response(requestConvertible)
        return response
    }
}

final class Route {}

struct Logger: OperaSwift.ObserverType {
    func willSendRequest(_ alamoRequest: Alamofire.Request, requestConvertible: URLRequestConvertible) {
        debugPrint(alamoRequest)
    }
}
