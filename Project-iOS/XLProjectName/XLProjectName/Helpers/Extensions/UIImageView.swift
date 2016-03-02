//
//  UIImageView.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import Foundation
import AlamofireImage


extension UIImageView {
    public func setImageWithURL(url: String) {
        af_setImageWithURL(NSURL(string: url)!, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.3), completion: nil)
    }
}
