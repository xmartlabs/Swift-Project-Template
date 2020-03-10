//
//  MultipartRouteType.swift
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

import Alamofire
import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
public typealias Image = UIImage
#elseif os(OSX)
public typealias Image = NSImage
#endif



// MARK: - MultipartRequestType

public struct MultipartData {

    let data: Data
    let fileName: String
    let mimeType: String
    let name: String

}

public protocol MultipartRouteType: OperaRouteType {

    var items: [MultipartData] { get }

}

public extension MultipartRouteType {

    var method: HTTPMethod {
        return .post
    }

}

// MARK: - ImageUploadRouteType

public enum ImageUploadEncoding {

    case png
    case jpeg(quality: CGFloat)

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        }
    }
    
    func encode(image: Image) -> Data? {
#if os(iOS) || os(tvOS) || os(watchOS)
        switch self {
        case .png:
            return image.pngData()
        case let .jpeg(quality):
            return image.jpegData(compressionQuality: quality)
        }
#elseif os(OSX)
        var format = NSBitmapImageRep.FileType.jpeg
        if case .png = self {
           format = NSBitmapImageRep.FileType.png
        }
        guard let data = image.tiffRepresentation, let rep = NSBitmapImageRep(data: data), let imgData = rep.representation(using: format, properties: [:]) else {
            return nil
        }
        return imgData
#endif
    }

}

public protocol ImageUploadRouteType: MultipartRouteType {

    var encoding: ImageUploadEncoding { get }
    var image: Image { get }
    var fileName: String { get }
    var imageName: String { get }

}

public extension ImageUploadRouteType {

    var items: [MultipartData] {
        return [
            MultipartData(
                data: encoding.encode(image: image) ?? Data(),
                fileName: fileName,
                mimeType: mimeType,
                name: imageName
            )
        ]
    }

    var encoding: ImageUploadEncoding {
        return .jpeg(quality: 0.80)
    }

    var fileName: String {
        return "\(imageName).\(encoding.fileExtension)"
    }

    var imageName: String {
        return "image"
    }

    var mimeType: String {
        return "image/\(encoding.fileExtension)"
    }

}

// MARK: - FileUploadRouteType

public protocol FileUploadRouteType: MultipartRouteType {

    var fileName: String { get }
    var fileUrl: URL { get }
    var mimeType: String { get }
    var name: String { get }

}

extension FileUploadRouteType {

    var items: [MultipartData] {
        return [
            MultipartData(
                data: (try? Data(contentsOf: fileUrl)) ?? Data(),
                fileName: fileName,
                mimeType: mimeType,
                name: name
            )
        ]
    }

    var fileName: String {
        return fileUrl.lastPathComponent
    }

    var name: String {
        return "file"
    }

}
