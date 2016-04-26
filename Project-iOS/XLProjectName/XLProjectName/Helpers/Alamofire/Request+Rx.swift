//
//  Request+Rx.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import UIKit

import Alamofire
import RxSwift

extension Alamofire.Request {
    
    public func rx_image() -> Observable<UIImage> {
        return Observable.create { [weak self] subscriber in
            self?.responseImage { response in
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
