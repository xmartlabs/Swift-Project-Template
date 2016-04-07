//  Manager.swift
//  Example-iOS ( https://github.com/xmartlabs/Example-iOS )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
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

class MyManager: Alamofire.Manager {
    
    static let singleton = MyManager()
    
    override init?(session: NSURLSession, delegate: Manager.SessionDelegate, serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        super.init(session: session, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    override init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: Alamofire.Manager.SessionDelegate = SessionDelegate(), serverTrustPolicyManager: Alamofire.ServerTrustPolicyManager? = nil)
    {
        super.init(configuration: configuration, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    override func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
        let result = super.request(URLRequest)
        debugPrint(result)
        return result
    }
    
    override func request(
                          method: Alamofire.Method,
                        _ URLString: URLStringConvertible,
                          parameters: [String: AnyObject]? = nil,
                          encoding: ParameterEncoding = .URL,
                          headers: [String: String]? = nil)
        -> Request {

        let result = super.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        debugPrint(result)
        return result
    }
}
