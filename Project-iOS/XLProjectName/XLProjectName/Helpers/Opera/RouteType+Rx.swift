//
//  RouteType+Rx.swift
//  Opera ( https://github.com/xmartlabs/Opera )
//
//  Copyright (c) 2019 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Alamofire
import Foundation
import RxCocoa
import RxSwift

public typealias OperaObjectResult<T> = (response: OperaResponse?, object: T)
public typealias OperaCollectionResult<T> = (response: OperaResponse?, object: [T])

extension Reactive where Base: OperaRouteType {

    /**
     Returns a `Single` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<T>`
     */
    public func object<T: OperaDecodable>(_ keyPath: String? = nil) -> Single<T> {
        return (base.manager as! RxManager).rx.object(base, keyPath: keyPath)
    }

    /**
     Returns a `Single` of [T] for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Single<[T]>`
     */
    public func collection<T: OperaDecodable>(_ collectionKeyPath: String? = nil) -> Single<[T]> {
        return (base.manager as! RxManager).rx.collection(base, collectionKeyPath: collectionKeyPath)
    }

    /**
     Returns a `Single` of Any for the current request. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - returns: An instance of `Single<Any>`
     */
    public func any() -> Single<Any> {
        return (base.manager as! RxManager).rx.any(base)
    }

    /**
     Returns a `Completable` sequence for the current request. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - returns: An instance of `Completable`
     */
    public func completable() -> Completable {
        return (base.manager as! RxManager).rx.completableResponse(base)
    }

    /**
     Returns a `Single` of OperaObjectResult<T> for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<OperaObjectResult<T>>`
     */
    public func objectResponse<T: OperaDecodable>(_ keyPath: String? = nil) -> Single<OperaObjectResult<T>> {
        return (base.manager as! RxManager).rx.objectResponse(base, keyPath: keyPath)
    }

    /**
     Returns a `Single` of OperaObjectResult<T> for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Single<OperaObjectResult<T>>`
     */
    public func collectionResponse<T: OperaDecodable>(_ collectionKeyPath: String? = nil) -> Single<OperaCollectionResult<T>> {
        return (base.manager as! RxManager).rx.collectionResponse(base, collectionKeyPath: collectionKeyPath)
    }

}

extension OperaRouteType {

    public var rx: Reactive<Self> {
        return Reactive(self)
    }

}
