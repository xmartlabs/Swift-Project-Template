//
//  PaginationRequestType+Rx.swift
//  Opera
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
import RxSwift
import Alamofire

extension Reactive where Base: PaginationRequestType {

    /**
     Returns a `Observable` of [Response] for the PaginationRequestType instance.
     If something goes wrong a Opera.Error error is propagated through the result sequence.

     - returns: An instance of `Observable<Response>`
     */
    var collection: Single<Base.Response> {
        let myPage = base.page
        return Single<Base.Response>.create { single in
            let req = NetworkManager.singleton.response(route: self.base) { (response: DataResponse<Base.Response, OperaError>) in
                switch response.result {
                  case .failure(let error):
                    single(.error(error))
                  case .success(let value):
                    single(.success(value))
                }
            }
            return Disposables.create {
               req.cancel()
            }
        }
    }
}
//        return NetworkManager.singleton.rx.object(route: self.base).map { (response: Base.Response) -> Base.Response in
//           let response = Base.Response.init(
//               elements: response.elements,
//               previousPage:
//                   .linkPagePrameter((self as? WebLinkingSettings)?
//                       .prevRelationName ?? Default.prevRelationName,
//                                     pageParameterName: (self as? WebLinkingSettings)?
//                                       .relationPageParamName ?? Default.relationPageParamName),
//               nextPage: serialized.response?
//                   .linkPagePrameter((self as? WebLinkingSettings)?
//                       .nextRelationName ?? Default.nextRelationName,
//                                     pageParameterName: (self as? WebLinkingSettings)?
//                                       .relationPageParamName ?? Default.relationPageParamName),
//               page: myPage
//           )
//        }
    


