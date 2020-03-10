//
//  NetworkManager.swift
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

import Foundation
import Alamofire

public typealias CompletionHandler = (OperaResult) -> Void

public protocol ObserverType {

    /// Called immediately before a request is sent over the network (or stubbed).
    func willSendRequest(_ alamoRequest: Request, requestConvertible: URLRequestConvertible)

}

public protocol ManagerType: class {

    var manager: SessionManager { get }
    var requestAdapter: RequestAdapter? { get set }
    var requestRetrier: RequestRetrier? { get set }
    var observers: [ObserverType] { get set }
    func response(
        _ requestConvertible: URLRequestConvertible,
        completion: @escaping CompletionHandler
    ) -> Request

}

open class OperaManager: ManagerType {

    open var observers: [ObserverType]
    open var manager: SessionManager
    open var requestAdapter: RequestAdapter? {
        didSet {
            manager.adapter = requestAdapter
        }
    }
    open var requestRetrier: RequestRetrier? {
        didSet {
            manager.retrier = requestRetrier
        }
    }

    public init(manager: SessionManager) {
        self.manager = manager
        self.observers = []
    }

    /**
     Makes a network request
     
     - parameter request:           the request to be made
     - parameter retryLeft:         how many times a retries are left if the request fails
     - parameter completionHandler: handler called when response comes in
     
     - returns: the request
     */
    open func response(
        _ request: URLRequestConvertible,
        completion: @escaping CompletionHandler
    ) -> Request {
        return self.retryCallback(
            request,
            retryLeft: (request as? OperaRouteType)?.retryCount ?? (request as? BasePaginationRequestType)?.route.retryCount ?? 0,
            completion: completion
        )
    }

    open func upload(
        _ multipartRequest: URLRequestConvertible,
        multipartData: [MultipartData],
        requestCreatedCallback callback: @escaping (Result<Request>) -> Void,
        completion: @escaping CompletionHandler) {

        manager.upload(
            multipartFormData: { multipartFormData in
                multipartData.forEach { data in
                    multipartFormData.append(data.data, withName: data.name, fileName: data.fileName, mimeType: data.mimeType)
                }
            },
            with: multipartRequest,
            encodingCompletion: { [weak self] encodingResult in
                switch encodingResult {
                case let .failure(error):
                    callback(.failure(error))
                    let operaResult = OperaResult(
                        result: .failure(OperaError.networking(
                            error: error,
                            request: multipartRequest.urlRequest,
                            response: nil,
                            json: nil
                        )),
                        requestConvertible: multipartRequest
                    )
                    completion(operaResult)
                case let .success(request, _, _):
                    callback(.success(request))

                    let result = request.validate()
                    if let progressiveRouteType = multipartRequest as? ProgressiveRouteType {
                        result.uploadProgress { progressiveRouteType.notifyUploadHandlers(with: $0) }
                        result.downloadProgress { progressiveRouteType.notifyDownloadHandlers(with: $0) }
                    }

                    self?.observers.forEach { $0.willSendRequest(result, requestConvertible: multipartRequest) }
                    request.response { dataResponse in
                        let result = toOperaResult(
                            multipartRequest,
                            originalRequest: dataResponse.request,
                            response: dataResponse.response,
                            data: dataResponse.data,
                            error: dataResponse.error
                        )
                        completion(result)
                    }
                }
            }
        )
    }

    /// Callback responsible for handling retries
    open func retryCallback(
        _ request: URLRequestConvertible,
        retryLeft: Int,
        completion: @escaping CompletionHandler
    ) -> Request {

        let result = manager.request(request).validate()

        if let progressiveRouteType = request as? ProgressiveRouteType {
            result.downloadProgress { progressiveRouteType.notifyDownloadHandlers(with: $0) }
        }

        observers.forEach { $0.willSendRequest(result, requestConvertible: request) }
        result.response { [weak self] dataResponse in
            let result: OperaResult =  toOperaResult(
                request,
                originalRequest: dataResponse.request,
                response: dataResponse.response,
                data: dataResponse.data,
                error: dataResponse.error)
            switch result.result {
            case .success:
                completion(result)
            case .failure(_):
                guard retryLeft > 0 else {
                    completion(result)
                    return
                }
                _ = self?.retryCallback(
                    request,
                    retryLeft: retryLeft - 1,
                    completion: completion
                )
            }
        }
        return result
    }

}

private func toOperaResult(
    _ requestConvertible: URLRequestConvertible,
    originalRequest: URLRequest?,
    response: HTTPURLResponse?,
    data: Data?,
    error: Error?
    ) -> OperaResult {
    switch (response, data, error) {
    case let (.some(response), .some(data), .none):
        return OperaResult(
            result: .success(
                OperaResponse(
                    statusCode: response.statusCode,
                    data: data,
                    response: response
            )),
            requestConvertible: requestConvertible
        )
    case let (_, _, .some(error)):
        return OperaResult(
            result: .failure(
                OperaError.networking(
                    error: error,
                    request: originalRequest,
                    response: response,
                    json: data as AnyObject)),
            requestConvertible: requestConvertible
        )
    default:
        return OperaResult(result: .failure(OperaError.networking(error: UnknownError(error: error),
            request: originalRequest,
            response: response,
            json: data as AnyObject)),
            requestConvertible: requestConvertible
        )
    }
}
