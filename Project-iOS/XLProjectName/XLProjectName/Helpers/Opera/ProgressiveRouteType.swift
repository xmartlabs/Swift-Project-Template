//
//  ProgressiveRouteType.swift
//  OperaSwift
//
//  Created by Diego Ernst on 5/11/17.
//
//

import Alamofire
import Foundation

public protocol ProgressiveRouteType: AdaptedRouteType {

}

extension ProgressiveRouteType {

    func notifyDownloadHandlers(with progress: Progress) {
        let handlers: [ProgressiveDownloadRouteType] = getWrappers()
        handlers.forEach { $0.progressHandler?(progress) }
    }

    func notifyUploadHandlers(with progress: Progress) {
        let handlers: [ProgressiveUploadRouteType] = getWrappers()
        handlers.forEach { $0.progressHandler?(progress) }
    }

    private func getWrappers<T>() -> [T] {
        var returnList = [T]()
        if let selfAsT = self as? T {
            returnList.append(selfAsT)
        }
        var adapted: AdaptedRouteType = self
        while let inner = adapted.routeType as? AdaptedRouteType {
            if let innerAsT = inner as? T {
                returnList.append(innerAsT)
            }
            adapted = inner
        }
        if let lastInnerAsT = adapted.routeType as? T {
            returnList.append(lastInnerAsT)
        }
        return returnList
    }

}

public protocol ProgressiveDownloadRouteType: ProgressiveRouteType {

    var progressHandler: Request.ProgressHandler? { get }
    func set(downloadProgressHandler: @escaping Request.ProgressHandler)

}

public protocol ProgressiveUploadRouteType: ProgressiveRouteType {

    var progressHandler: Request.ProgressHandler? { get }
    func set(uploadProgressHandler: @escaping Request.ProgressHandler)

}
