// Author - Santosh Rajan

import Foundation

func JSONStringify(value: AnyObject, prettyPrinted: Bool = true) -> String {
    let options: NSJSONWritingOptions = prettyPrinted ? .PrettyPrinted : []
    if NSJSONSerialization.isValidJSONObject(value) {
        if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: options), let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
            return string as String
        }
    }
    return ""
}

