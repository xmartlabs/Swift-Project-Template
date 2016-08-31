//
//  UIImageView.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage


extension UIImageView {
    public func setImageWithURL(url: String, filter: ImageFilter? = nil, placeholder: UIImage? = nil, completion: (Response<UIImage, NSError> -> Void)? = nil) {
        af_setImageWithURL(NSURL(string: url)!, placeholderImage: placeholder, filter: filter, imageTransition: .CrossDissolve(0.3), completion: {
            (response: Response<UIImage, NSError>) in
            if let error = response.result.error {
                print(error.localizedDescription)
            }
            completion?(response)
        })
    }
}
