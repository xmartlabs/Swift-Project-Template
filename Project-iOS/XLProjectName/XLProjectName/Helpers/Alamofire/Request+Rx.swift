//
//  Request+RxSwift.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import UIKit

import Alamofire
import Argo
import RxSwift

extension Alamofire.Request {
    
    public func rx_object<T: Decodable where T == T.DecodedType>() -> Observable<T> {
        return Observable.create { [weak self] subscriber in
             self?.responseObject { (response: Response<T, NetworkError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let entity):
                    subscriber.onNext(entity)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }.doOnError(NetworkManager.generalErrorHandler)
    }
    
    public func rx_collection<T: Decodable where T == T.DecodedType>() -> Observable<[T]> {
        return Observable.create { [weak self] subscriber in
            self?.responseCollection { (response: Response<[T], NetworkError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let entity):
                    subscriber.onNext(entity)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }.doOnError(NetworkManager.generalErrorHandler)
    }
    
    public func rx_anyObject() -> Observable<AnyObject> {
        return Observable.create { [weak self] subscriber in
            self?.responseAnyObject { (response: Response<AnyObject, NetworkError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let anyObject):
                    subscriber.onNext(anyObject)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }.doOnError(NetworkManager.generalErrorHandler)
    }
    
    public func rx_image() -> Observable<UIImage> {
        return Observable.create { [weak self] subscriber in
            self?.responseImage() { response in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let image):
                    subscriber.onNext(image)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }
    }
    
}
