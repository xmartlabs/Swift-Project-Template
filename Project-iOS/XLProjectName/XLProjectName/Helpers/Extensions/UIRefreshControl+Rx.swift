//
//  UIRefreshControl+Rx.swift
//  XLProjectName
//
//  Created by Diego Medina on 3/29/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension UIControl {
    
    var rx_valueChanged: ControlEvent<Void> {
        return rx_controlEvent(.ValueChanged)
    }
}
