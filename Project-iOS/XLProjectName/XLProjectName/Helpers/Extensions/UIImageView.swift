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

    public func setImageWithURL(_ url: String, filter: ImageFilter? = nil, placeholder: UIImage? = nil, completion: ((DataResponse<UIImage>) -> Void)? = nil) {
        af_setImage(
            withURL: URL(string: url)!,
            placeholderImage: placeholder,
            filter: filter,
            imageTransition: .crossDissolve(0.3),
            completion: completion)
    }
}
