//
//  NSURLResponse.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/23/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import WebLinking

extension NSHTTPURLResponse {
    
    var previousLinkPageValue: String? {
        return linkPagePrameter("prev")
    }
    
    var nextLinkPageValue: String? {
        return linkPagePrameter("next")
    }
    
    var firstLinkPageValue: String? {
        return linkPagePrameter("next")
    }
    
    var lastLinkPageValue: String? {
        return linkPagePrameter("last")
    }
    
    private func linkPagePrameter(relation: String) -> String? {
        guard let uri = self.findLink(relation: relation)?.uri else { return nil }
        let components = NSURLComponents(string: uri)
        return components?.queryItems?.filter { $0.name == "page" }.first?.value
    }
}
