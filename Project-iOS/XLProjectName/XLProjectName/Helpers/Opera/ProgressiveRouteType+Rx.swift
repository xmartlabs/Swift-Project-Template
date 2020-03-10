//
//  MultipartRouteType+Rx.swift
//  OperaSwift
//
//  Created by Diego Ernst on 5/10/17.
//
//

import Alamofire
import Foundation
import RxCocoa
import RxSwift

// MARK: - ProgressiveRouteType Wrappers

public class BaseProgressiveDownloadRouteType: ProgressiveDownloadRouteType {

    public let routeType: OperaRouteType
    public var progressHandler: Request.ProgressHandler?

    public init(routeType: OperaRouteType) {
        self.routeType = routeType
    }

    public func set(downloadProgressHandler: @escaping Request.ProgressHandler) {
        self.progressHandler = downloadProgressHandler
    }

}

public class BaseProgressiveMultipartDownloadRouteType: BaseProgressiveDownloadRouteType {

}

public class BaseProgressiveUploadRouteType: ProgressiveUploadRouteType {

    public let routeType: OperaRouteType
    public var progressHandler: Request.ProgressHandler?

    public init(routeType: OperaRouteType) {
        self.routeType = routeType
    }

    public func set(uploadProgressHandler: @escaping Request.ProgressHandler) {
        self.progressHandler = uploadProgressHandler
    }

}

// MARK: - Reactive ProgressiveRouteType

extension Reactive where Base: OperaRouteType {

    public func downloadProgress(downloadProgressHandler: @escaping Request.ProgressHandler)
        -> Reactive<BaseProgressiveDownloadRouteType> {
        let adapted = BaseProgressiveDownloadRouteType(routeType: base)
        adapted.set(downloadProgressHandler: downloadProgressHandler)
        return Reactive<BaseProgressiveDownloadRouteType>(adapted)
    }

}

extension Reactive where Base: MultipartRouteType {

    public func downloadProgress(downloadProgressHandler: @escaping Request.ProgressHandler)
        -> Reactive<BaseProgressiveMultipartDownloadRouteType> {
        let adapted = BaseProgressiveMultipartDownloadRouteType(routeType: base)
        adapted.set(downloadProgressHandler: downloadProgressHandler)
        return Reactive<BaseProgressiveMultipartDownloadRouteType>(adapted)
    }

}

extension Reactive where Base: MultipartRouteType {

    public func uploadProgress(uploadProgressHandler: @escaping Request.ProgressHandler)
        -> Reactive<BaseProgressiveUploadRouteType> {
        let adapted = BaseProgressiveUploadRouteType(routeType: base)
        adapted.set(uploadProgressHandler: uploadProgressHandler)
        return Reactive<BaseProgressiveUploadRouteType>(adapted)
    }

}

extension Reactive where Base: BaseProgressiveMultipartDownloadRouteType {

    public func uploadProgress(uploadProgressHandler: @escaping Request.ProgressHandler)
        -> Reactive<BaseProgressiveUploadRouteType> {
        let adapted = BaseProgressiveUploadRouteType(routeType: base)
        adapted.set(uploadProgressHandler: uploadProgressHandler)
        return Reactive<BaseProgressiveUploadRouteType>(adapted)
    }

}

extension Reactive where Base: BaseProgressiveUploadRouteType {

    public func uploadProgress(uploadProgressHandler: @escaping Request.ProgressHandler)
        -> Reactive<BaseProgressiveUploadRouteType> {
        let adapted = BaseProgressiveUploadRouteType(routeType: base)
        adapted.set(uploadProgressHandler: uploadProgressHandler)
        return Reactive<BaseProgressiveUploadRouteType>(adapted)
    }

}
