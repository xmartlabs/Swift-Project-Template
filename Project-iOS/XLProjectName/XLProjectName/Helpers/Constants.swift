//
//  Constants.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 XLOrganizationName. All rights reserved.
//


import Foundation
import UIKit

struct Constants {

	struct Network {
#if DEBUG
        static let BASE_URL = URL(string: "https://api.github.com")!
#else
        static let BASE_URL = URL(string: "https://api.github.com")!
#endif
        static let AuthTokenName = "Authorization"
        static let SuccessCode = 200
        static let successRange = 200..<300
        static let Unauthorized = 401
        static let NotFoundCode = 404
        static let ServerError = 500
    }

    struct Keychain {
        static let SERVICE_IDENTIFIER = UIApplication.applicationVersionNumber
        static let SESSION_TOKEN = "session_token"
        static let DEVICE_TOKEN = "device_token"
    }
    
    struct Formatters {
        
        static let debugConsoleDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone(identifier: "UTC")!
            return formatter
        }()
        
    }
    
    struct Debug {
#if DEBUG
        static let crashlytics = true
        static let jsonResponse = true
#else
        static let crashlytics = false
        static let jsonResponse = false
#endif
    }

// MARK: - Text Styles
    enum TextStyle {

        case body(alignment: NSTextAlignment)
        case title

        func getFont() -> UIFont {
            switch self {
            case .body:
                return UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body), size: 22)
            case .title:
                return UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1), size: 16)
            }
        }

        var textAttributes: [NSAttributedString.Key: Any]? {
            switch self {
            case let .body(alignment):
                let font = getFont()
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 20 - font.lineHeight
                paragraphStyle.alignment = alignment
                return [NSAttributedString.Key.paragraphStyle: paragraphStyle]
            case .title:
                return [NSAttributedString.Key.kern: -0.53]
            }
        }
    }

}

// MARK: - Colors
extension UIColor {
    static var primaryColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

// MARK: - Errors
enum BaseError: Error {
    case networkError(error: NSError)
}

extension BaseError {
    
    var errorDescription: String {
        switch self {
        case .networkError(_):
            return "No internet connection"
        }
    }
}
