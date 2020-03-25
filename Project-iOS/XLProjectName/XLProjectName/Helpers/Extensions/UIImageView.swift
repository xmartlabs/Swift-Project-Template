//
//  UIImageView.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

extension UIImageView {
    public func setImageWithURL(_ url: String, filter: ImageFilter? = nil, placeholder: UIImage? = nil, completion: ((AFIDataResponse<UIImage>) -> Void)? = nil) {
        
        self.af.setImage(withURL: URL(string: url)!, cacheKey: nil, placeholderImage: placeholder, serializer: nil, filter: filter, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false) { (response: AFIDataResponse<UIImage>) in
            response.error.map { print($0.localizedDescription) }
            completion?(response)
        }
    }
}
