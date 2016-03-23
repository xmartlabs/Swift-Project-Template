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
        return Observable<Response<T, NetworkError>>.create { subscriber in
            self.responseObject() { (response: Response<T, NetworkError>) in
                subscriber.onNext(response)
                subscriber.onCompleted()
            }
            return NopDisposable.instance
        }.map(emitResponseResult)
    }
    
    public func rx_objectCollection<T: Decodable where T == T.DecodedType>() -> Observable<[T]> {
        return Observable<Response<[T], NetworkError>>.create { subscriber in
            self.responseCollection() { (response: Response<[T], NetworkError>) in
                subscriber.onNext(response)
                subscriber.onCompleted()
            }
            return NopDisposable.instance
        }.map(emitResponseResult)
    }
    
    public func rx_anyObject() -> Observable<AnyObject> {
        return Observable<Response<AnyObject, NetworkError>>.create { subscriber in
            self.responseAnyObject() { (response: Response<AnyObject, NetworkError>) in
                subscriber.onNext(response)
                subscriber.onCompleted()
            }
            return NopDisposable.instance
        }.map(emitResponseResult)
    }
    
    public func rx_image() -> Observable<UIImage> {
        return Observable<Response<UIImage, NSError>>.create() { subscriber in
            self.responseImage() { response in
                subscriber.onNext(response)
                subscriber.onCompleted()
            }
            return NopDisposable.instance
        }.map(emitResponseResult)
    }
    
    private func emitResponseResult<T, U: ErrorType>(response: Response<T, U>) throws -> T {
        switch response.result {
        case .Failure(let error):
            throw error
        case .Success(let entity):
            return entity
        }
    }
    
}
