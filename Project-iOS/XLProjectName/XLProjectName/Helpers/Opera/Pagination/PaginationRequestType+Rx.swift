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

extension Reactive where Base: PaginationRequestType, Base.Response.Element: OperaDecodable {

    /**
     Returns a `Observable` of [Response] for the PaginationRequestType instance.
     If something goes wrong a Opera.Error error is propagated through the result sequence.

     - returns: An instance of `Observable<Response>`
     */
    var collection: Single<Base.Response> {
        let myPage = base.page
        return (base.route.manager as! RxManager).rx.response(base).flatMap { operaResult -> Single<Base.Response> in
            let serialized: DataResponse<[Base.Response.Element]> = operaResult
                .serializeCollection(self.base.collectionKeyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let elements):
                let response = Base.Response.init(
                    elements: elements,
                    previousPage: serialized.response?
                        .linkPagePrameter((self as? WebLinkingSettings)?
                            .prevRelationName ?? Default.prevRelationName,
                                          pageParameterName: (self as? WebLinkingSettings)?
                                            .relationPageParamName ?? Default.relationPageParamName),
                    nextPage: serialized.response?
                        .linkPagePrameter((self as? WebLinkingSettings)?
                            .nextRelationName ?? Default.nextRelationName,
                                          pageParameterName: (self as? WebLinkingSettings)?
                                            .relationPageParamName ?? Default.relationPageParamName),
                    page: myPage
                )
                return Single.just(response)
            }
        }
    }

}
