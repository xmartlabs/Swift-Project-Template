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

/**
 Adapter that provides composition to be able to have more than one adapter
 integrated at the same time.
*/

open class CompositeAdapter: HashableRequestAdapter {
    /// Our "pipeline" of adapters.
    private var adapters = [String: HashableRequestAdapter]()
    /// Empty init, you can subclass it to add your adapters here.
    public init() {}

    public convenience init(adapters: [HashableRequestAdapter]) {
        self.init()
        self.append(adapters: adapters)
    }
    /// implementation of the adapt function to conform Alamofire.RequestAdapter
    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return adapters.reduce(urlRequest) { (try? $1.value.adapt($0)) ?? $0 }
    }
    /**
     Appends a new adapter at the end of the pipeline.
     - parameter adapter: The adapter to be added.
    */
    open func append(adapter: HashableRequestAdapter) {
        adapters[adapter.key] = adapter
    }
    /**
     Appends a collection of adapters to the pipeline.
     - parameter adapters: The adapters to be added in order.
     */
    open func append(adapters: [HashableRequestAdapter]) {
        adapters.forEach {
            self.adapters[$0.key] = $0
        }
    }
    /**
     Removes an adapter from the pipeline.
     - parameter key: The key of the adapter.
    */
    open func remove(adapter key: String) {
        adapters.removeValue(forKey: key)
    }
}
