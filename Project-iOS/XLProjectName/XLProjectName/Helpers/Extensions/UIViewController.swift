
//
//  File.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 'XLOrganizationName'. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

extension UIViewController {
    
    /// shows an UIAlertController alert with error title and message
    public func showError(_ title: String, message: String? = nil) {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.showError(title, message: message)
            }
            return
        }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.view.tintColor = UIWindow.appearance().tintColor
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}


extension Reactive where Base: UIViewController {
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }
    
    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }
}
