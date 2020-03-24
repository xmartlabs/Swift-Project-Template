//  Helpers-iOS.swift
//  Opera ( https://github.com/xmartlabs/Opera )
//
//  Copyright (c) 2019 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import RxSwift
import RxCocoa
import Foundation
import UIKit

extension UIControl {

    public var rx: Reactive<UIControl> {
        return Reactive(self)
    }

}

extension Reactive where Base: UIControl {
    /// Reactive wrapper for UIControlEvents.ValueChanged target action pattern.
    public var valueChanged: ControlEvent<Void> {
        return base.rx.controlEvent(.valueChanged)
    }
}

extension Reactive where Base: UIScrollView {

    public var reachedBottom: Observable<Void> {
        return didEndDecelerating.flatMap { (_) -> Observable<Void> in
                return self.base.isTableViewScrolledToBottom() ?
                    Observable.just(()) : Observable.empty()
        }
    }
}

extension UIScrollView {

    public func isTableViewScrolledToBottom() -> Bool {
        let visibleHeight = frame.height - contentInset.top - contentInset.bottom
        let y = contentOffset.y + contentInset.top
        let threshold = max(0.0, contentSize.height - visibleHeight)
        return y >= threshold
    }
}
