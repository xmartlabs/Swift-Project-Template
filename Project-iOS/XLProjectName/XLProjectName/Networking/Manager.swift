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

    static let singleton: NetworkManager = {
        var requestInterceptor = Interceptor(adapters: [], retriers: [RetryPolicy()])
        return NetworkManager(session: Session(interceptor: requestInterceptor, eventMonitors: [LoggerEventMonitor()]))
    }()

    override init(session: Alamofire.Session) {
        super.init(session: session)
    }
    
    func deviceUpdate(token: String) -> Completable{
        return rx.completable(route: Route.Device.Update(token: token))
    }
    
    func login(route: Route.User.Login) -> Single<Any> {
        return rx.any(route: route)
    }
    
    func getInfo(route: Route.User.GetInfo) -> Single<Any> {
        return rx.any(route: route)
    }
}


public typealias OperaDataResponse<Success> = DataResponse<Success, OperaError>

extension Reactive where Base: NetworkManager {

    /**
     Returns a `Single` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<T>`
     */
    func object<T: Decodable>(route: URLRequestConvertible) -> Single<T> {
        return Single.create { subscriber in
            let req = self.base.session.request(route)
            req.responseDecodable(decoder: self.base.decoder) { (dataResponse: AFDataResponse<T>) in
                switch dataResponse.result {
                case .failure(let error):
                    subscriber(.error(OperaError.afError(error: error)))
                case .success(let decodable):
                    subscriber(.success(decodable))
                }
            }
            return Disposables.create {
                req.cancel()
            }
        }
    }
    
    func any(route: URLRequestConvertible) -> Single<Any> {
        return Single.create { single in
            let req = self.base.session.request(route)
            req.responseJSON(completionHandler: { (dataResponse: AFDataResponse<Any>) in
                switch dataResponse.result {
                  case .failure(let error):
                    single(.error(OperaError.afError(error: error)))
                  case .success(let any):
                    single(.success(any))
                }
            })
            return Disposables.create {
                req.cancel()
            }
        }
    }
    
    func completable(route: URLRequestConvertible) -> Completable {
        return Completable.create { completable in
            let req = self.base.session.request(route)
            req.response(completionHandler: { (dataResponse: AFDataResponse<Data?>) in
                switch dataResponse.result {
                  case .failure(let error):
                    completable(.error(OperaError.afError(error: error)))
                  case .success(_):
                    completable(.completed)
                }
            })
            return Disposables.create {
                req.cancel()
            }
        }
    }
}




extension NetworkManager {
    var rx: Reactive<NetworkManager> {
        return Reactive(self)
    }
}
