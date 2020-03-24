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
import RxSwift
import RxCocoa

public protocol ManagerType: class {

    var session: Session { get }
}

open class OperaManager: ManagerType {
    open var session: Session
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder();
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    public init(session: Session) {
        self.session = session
    }
}


open class RxManager: OperaManager {

    private let disposeBag = DisposeBag()

    public override init(session: Session) {
        super.init(session: session)
    }
    
    public func response<T: Decodable>(route: URLRequestConvertible, completionHandler: @escaping (OperaDataResponse<T>) -> Void) -> DataRequest {
        let request = self.session.request(route)
        request.responseDecodable(decoder: self.decoder) { (response: DataResponse<T, AFError>) in
            completionHandler(OperaDataResponse(request: response.request, response: response.response, data: response.data, metrics: response.metrics, serializationDuration: response.serializationDuration, result: response.result.mapError { .afError(error: $0) }))
        }
        return request
    }
}
