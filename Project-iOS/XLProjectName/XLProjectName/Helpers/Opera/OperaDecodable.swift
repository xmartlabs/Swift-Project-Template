//  OperaDecodable.swift
//  Opera ( https://github.com/xmartlabs/Opera )
//
//  Copyright (c) 2019 Xmartlabs SRL  ( http://xmartlabs.com )
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

/**
 *  Entities that conforms to OperaDecotable are able to 
    convert a AnyObject to itself. Notice that Opera 
    expects its entities to conform to this protocol. 
    OperaDecodable allows us to use the JSON parsing library
    that we feel confortable with.
 *  For instance to use Decodable we just need 
    to declare protocol conformance.
 *  In order to use Argo as JSON parsing library each json 
    parseable entity should declare OperaDecodable protocol conformance. 
    We also need to implement `static func decode(json: AnyObject) throws -> Self` 
    to each argo parseable entity and probably the most elegant way is through
    protocol extensions as shown bellow.
 *
 *      extension Argo.Decodable where Self.DecodedType == Self, Self: OperaDecodable {
 *          static func decode(json: AnyObject) throws -> Self {
 *              let decoded = decode(JSON.parse(json))
 *              switch decoded {
 *              case .success(let value):
 *                  return value
 *              case .failure(let error):
 *                  throw error
 *              }
 *          }
 *      }
 */
public protocol OperaDecodable {
    static func decode(_ json: Any) throws -> Self
}

public extension OperaDecodable where Self: Decodable {
    
    static func decode(_ json: Any) throws -> Self {
        
        let decoder = JSONDecoder();
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return try decoder.decode(Self.self, from: data)
    }
}
