//
//  UIImageView.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import AlamofireImage


extension UIImageView {
    public func setImageWithURL(url: String) {
        af_setImageWithURL(NSURL(string: url)!, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.3), completion: nil)
    }
}
