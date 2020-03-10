//
//  ManagerType+Rx.swift
//  Opera
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
import RxSwift
import RxCocoa

extension Reactive where Base: RxManager {

    /**
     Returns a `Single` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<T>`
     */
    func object<T: OperaDecodable>(_ route: OperaRouteType, keyPath: String? = nil) -> Single<T> {
        return base.rx.response(route).flatMap { operaResult -> Single<T> in
            let serialized: DataResponse<T> = operaResult.serializeObject(keyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(anyObject)
            }
        }
    }

    /**
     Returns a `Single` of [T] for the current request. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Single<[T]>`
     */
    func collection<T: OperaDecodable>(_ route: OperaRouteType, collectionKeyPath: String? = nil) -> Single<[T]> {
        return base.rx.response(route).flatMap { operaResult -> Single<[T]> in
            let serialized: DataResponse<[T]> = operaResult.serializeCollection(collectionKeyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(anyObject)
            }
        }
    }

    /**
     Returns an `Single` of AnyObject for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.

     - returns: An instance of `Single<AnyObject>`
     */
    func any(_ route: OperaRouteType) -> Single<Any> {
        return base.rx.response(route).flatMap { operaResult -> Single<Any> in
            let serialized = operaResult.serializeAny()
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(anyObject)
            }
        }
    }

    /**
     Returns a `Single` of (OperaResponse?,T) for the current request. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<(OperaResponse?,T)>`
     */
    func objectResponse<T: OperaDecodable>(_ route: OperaRouteType, keyPath: String? = nil) -> Single<OperaObjectResult<T>> {
        return base.rx.response(route).flatMap { operaResult -> Single<OperaObjectResult<T>> in
            let serialized: DataResponse<T>  = operaResult.serializeObject(keyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(OperaObjectResult(operaResult.operaResponse, anyObject))
            }
        }
    }

    /**
     Returns a `Single` of (OperaResult?, [T]) for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.
     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Single<(OperaResult?, [T])>`
    */
    func collectionResponse<T: OperaDecodable>(_ route: OperaRouteType, collectionKeyPath: String? = nil) -> Single<OperaCollectionResult<T>> {
        return base.rx.response(route).flatMap { operaResult -> Single<OperaCollectionResult<T>> in
            let serialized: DataResponse<[T]> = operaResult.serializeCollection(collectionKeyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(OperaCollectionResult(operaResult.operaResponse, anyObject))
            }
        }
    }

    /**
     Returns an `Single` of `OperaResult` for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter requestConvertible: the request that will be performed.

     - returns: An instance of `Single<OperaResult>`
     */
    func response(_ requestConvertible: URLRequestConvertible) -> Single<OperaResult> {
        return base.response(requestConvertible)
    }

    /**
     Returns a `Completable` sequence for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter requestConvertible: the request that will be performed.

     - returns: An instance of `Completable`
     */
    func completableResponse(_ requestConvertible: URLRequestConvertible) -> Completable {
        return base.completableResponse(requestConvertible)
    }
}

open class RxManager: OperaManager {

    private let disposeBag = DisposeBag()

    public var rx: Reactive<RxManager> {
        return Reactive(self)
    }

    public override init(manager: SessionManager) {
        super.init(manager: manager)
    }

    open func response(_ requestConvertible: URLRequestConvertible) -> Single<OperaResult> {
        if let multipart = multipartRouteType(requestConvertible) {
            return upload(multipart.routeType, data: multipart.data)
        }
        return Single.create { [weak self] subscriber in
            guard let `self` = self else {
                subscriber(.error(UnknownError(error: nil)))
                return Disposables.create()
            }
            let req = self.response(requestConvertible) { result in
                switch result.result {
                case .failure(let error):
                    subscriber(.error(error))
                case .success:
                    subscriber(.success(result))
                }
            }
            return Disposables.create {
                req.cancel()
            }
        }
    }

    open func completableResponse(_ requestConvertible: URLRequestConvertible) -> Completable {
        if let multipart = multipartRouteType(requestConvertible) {
            return completableUpload(multipart.routeType, data: multipart.data)
        }
        return singleToCompletable(single: response(requestConvertible))
    }

    open func upload(_ multipartRequest: URLRequestConvertible, data: [MultipartData]) -> Single<OperaResult> {
        return Single.create { [weak self] subscriber in
            guard let `self` = self else {
                subscriber(.error(UnknownError(error: nil)))
                return Disposables.create()
            }

            var request: Request? = nil
            self.upload(
                multipartRequest,
                multipartData: data,
                requestCreatedCallback: { result in
                    switch result {
                    case .failure(let error):
                        subscriber(.error(error))
                    case let .success(req):
                        request = req
                    }
                },
                completion: { result in
                    switch result.result {
                    case .failure(let error):
                        subscriber(.error(error))
                    case .success:
                        subscriber(.success(result))
                    }
                }
            )

            return Disposables.create {
                if let req = request {
                    req.cancel()
                }
            }
        }
    }

    open func completableUpload(_ multipartRequest: URLRequestConvertible, data: [MultipartData]) -> Completable {
        return singleToCompletable(single: upload(multipartRequest, data: data))
    }

    fileprivate func singleToCompletable<T>(single: Single<T>) -> Completable {
        let disposeBag = self.disposeBag
        return Completable.create { subscriber in
            single.subscribe(
                onSuccess: { _ in
                    subscriber(.completed)
                },
                onError: { error in
                    subscriber(.error(error))
                }
            )
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }

    fileprivate func multipartRouteType(_ request: URLRequestConvertible) -> (routeType: OperaRouteType, data: [MultipartData])? {
        guard let routeType = request as? OperaRouteType else {
            return nil
        }
        if let multipart = routeType as? MultipartRouteType {
            return (routeType: multipart, data: multipart.items)
        }
        if let adaptedRouteType = routeType as? AdaptedRouteType, let innerMultipartRoute = adaptedRouteType.innerRouteType as? MultipartRouteType {
            return (routeType: routeType, data: innerMultipartRoute.items)
        }
        return nil
    }

}
