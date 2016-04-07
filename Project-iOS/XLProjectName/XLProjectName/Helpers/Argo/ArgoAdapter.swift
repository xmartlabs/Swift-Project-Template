//
//  JsonParserAdapter.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 4/4/16. ( http://xmartlabs.com )
//    Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Decodable
import Result
import Argo
import Foundation
import Opera

extension Argo.Decodable where Self.DecodedType == Self, Self: OperaDecodable {
    static func decode(json: AnyObject) throws -> Self {
        let decoded = decode(JSON.parse(json))
        switch decoded {
        case .Success(let value):
            return value
        case .Failure(let error):
            throw error
        }
    }
}
