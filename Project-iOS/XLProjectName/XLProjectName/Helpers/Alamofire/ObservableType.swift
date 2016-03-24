//
//  Alamofire+ObservableType.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOnNetworkError(onError: (NetworkError throws -> Void)) -> Observable<E> {
        return self.doOnError() { error in
            guard let error = error as? NetworkError else { return }
            try onError(error)
        }
    }
    
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOnFinished(eventHandler: () throws -> Void) -> Observable<E> {
        return self.doOn { event in
            switch event {
            case .Next: return
            default: try eventHandler()
            }
        }
    }
}
