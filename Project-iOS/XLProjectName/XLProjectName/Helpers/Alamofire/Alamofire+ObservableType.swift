//
//  Alamofire+ObservableType.swift
//  XLProjectName
//
//  Created by Diego Medina on 3/23/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOnError(onError: (NetworkError throws -> Void)) -> RxSwift.Observable<Self.E> {
        return self.doOnError() { error in
            guard let error = error as? NetworkError else { return }
            try onError(error)
        }
    }
    
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOnFinished(eventHandler: () throws -> Void) -> RxSwift.Observable<Self.E> {
        return self.doOn { event in
            switch event {
            case .Next(_): return
            default: try eventHandler()
            }
        }
    }
    
}