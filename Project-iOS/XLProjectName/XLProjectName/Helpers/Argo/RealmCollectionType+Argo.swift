//
//  RealmCollectionTypeArgo.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/17/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import RealmSwift

extension RealmCollectionType where Element: Decodable, Element == Element.DecodedType {
    
    static func decode(j: JSON) -> Decoded<List<Element>> {
        switch j {
        case let .Array(a): return realmSequence(a.map(Element.decode))
        default: return .typeMismatch("List", actual: j)
        }
    }
}

public func realmSequence<T>(xs: [Decoded<T>]) -> Decoded<List<T>> {
    var accum = List<T>()
    accum.reserveCapacity(xs.count)
    for x in xs {
        switch x {
        case let .Success(value): accum.append(value)
        case let .Failure(error): return .Failure(error)
        }
    }
    
    return pure(accum)
}


infix operator <||| { associativity left precedence 150 }
infix operator <|||? { associativity left precedence 150 }

// MARK: Arrays

// Pull array from JSON
public func <||| <A where A: Decodable, A == A.DecodedType>(json: JSON, key: String) -> Decoded<List<A>> {
    return json <||| [key]
}

// Pull embedded array from JSON
public func <||| <A where A: Decodable, A == A.DecodedType>(json: JSON, keys: [String]) -> Decoded<List<A>> {
    return flatReduce(keys, initial: json, combine: decodedJSON) >>- List<A>.decode
}
