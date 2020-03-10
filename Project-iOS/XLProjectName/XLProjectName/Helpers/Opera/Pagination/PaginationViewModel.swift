//  PaginationViewModel.swift
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

import Alamofire
import Foundation
import RxSwift
import RxCocoa
import Action

/// Reactive View Model helper to load list of OperaDecodable items.
open class PaginationViewModel<PaginationRequest: PaginationRequestType>
    where PaginationRequest.Response.Element: OperaDecodable {
    
    
    private enum LoadActionInput {
        case page(page: String)
        case query(query: String)
        case filter(filter: FilterType)
    }

    /// pagination request
    var paginationRequest: PaginationRequest
    public typealias LoadingType = (Bool, String)
    
    /// trigger a refresh, if emited item is true it will cancel pending 
    //  request and make a new one. if false it will
    //  not refresh if there is a request in progress.
    public let refreshTrigger = PublishSubject<Void>()
    /// trigger a next page load, it makes a new request for
    //  the nextPage value provided by lastest request sent to server.
    public let loadNextPageTrigger = PublishSubject<Void>()
    /// Cancel any in progress request and start a new one using the query string provided.
    public let queryTrigger = PublishSubject<String>()
    /// Cancel any in progress request and start a new one using the filter parameters provided.
    public let filterTrigger = PublishSubject<FilterType>()

    /// Allows subscribers to get notified about networking errors
    public let errors: Driver<Error>
    /// Indicates if there is a next page to load. 
    //  hasNextPage value is the result of getting next link relation from latest response.
    public let hasNextPage = BehaviorRelay<Bool>(value: false)
    /// Indicates is there is a request in progress and what is the request page.
    public let fullloading = BehaviorRelay<LoadingType>(value: (false, Default.firstPageParameterValue))
    
    public let loading = BehaviorRelay<Bool>(value: false)
    
    /// Elements array from first page up to latest fetched page.
    public let elements = BehaviorRelay<[PaginationRequest.Response.Element]>(value: [])
    
    private let loadAction: Action<LoadActionInput, PaginationRequest.Response>

    fileprivate var disposeBag = DisposeBag()

    /**
     Initialize a new PaginationViewModel instance.
     
     - parameter paginationRequest: pagination request.
     
     - returns: A PaginationViewModel instance.
     */
    public init(paginationRequest: PaginationRequest) {
        self.paginationRequest = paginationRequest
        
        var _paginationRequest = paginationRequest
        self.loadAction = Action { input in
            switch input {
            case .page(let page):
                _paginationRequest = _paginationRequest.routeWithPage(page)
            case .query(let query):
                _paginationRequest = _paginationRequest.routeWithQuery(query)
            case .filter(let filter):
                _paginationRequest = _paginationRequest.routeWithFilter(filter)
            }
            return _paginationRequest.rx.collection.asObservable()
        }
        
        self.errors = loadAction.errors
            .asDriver(onErrorDriveWith: .empty())
            .flatMap { error -> Driver<Error> in
                switch error {
                case .underlyingError(let error):
                    return Driver.just(error)
                case .notEnabled:
                    return Driver.empty()
                }
            }
        
        let fistPageValue = (self.paginationRequest as? PaginationRequestTypeSettings)?.firstPageParameterValue ?? Default.firstPageParameterValue
        loadAction
            .elements
            .asDriver(onErrorDriveWith: .empty())
            .scan([]) {
                $1.page == fistPageValue ? $1.elements : $0 + $1.elements
            }
            .startWith([])
            .drive(self.elements)
            .disposed(by: disposeBag)
        
        loadAction.executing
            .asDriver(onErrorJustReturn: false)
            .drive(self.loading)
            .disposed(by: disposeBag)
        
        loadAction.elements.map { $0.hasNextPage }
            .asDriver(onErrorJustReturn: self.hasNextPage.value)
            .drive(self.hasNextPage)
            .disposed(by: disposeBag)
        
        
        let refreshTrigger = self.refreshTrigger.map { _ in
                return LoadActionInput.page(page: fistPageValue)
            }
            
//        refreshTrigger.bind(to: self.loadAction.inputs)
//            .disposed(by: disposeBag)
        
        let queryObservable = self.queryTrigger.map { LoadActionInput.query(query: $0) }
            
//        queryObservable.bind(to: self.loadAction.inputs)
//            .disposed(by: disposeBag)
//
        
        let filterObservable = self.filterTrigger.map { LoadActionInput.filter(filter: $0) }
        
//        filterObservable
//            .bind(to: self.loadAction.inputs)
//            .disposed(by: disposeBag)
//
        
        let loadNextPageObservable = self.loadNextPageTrigger.withLatestFrom(loadAction.elements).flatMap { $0.nextPage.map { return Observable.of(LoadActionInput.page(page: $0)) } ?? Observable.empty() }

//        loadNextPageObservable.bind(to: self.loadAction.inputs)
//            .disposed(by: disposeBag)
//
        
        let newInputTrigger = Observable.merge(queryObservable, filterObservable, loadNextPageObservable, refreshTrigger)
        newInputTrigger
            .bind(to: self.loadAction.inputs)
            .disposed(by: disposeBag)
        
        
        
        Driver.combineLatest(loadAction.executing.asDriver(onErrorDriveWith: .empty()).distinctUntilChanged(),  newInputTrigger.asDriver(onErrorJustReturn: LoadActionInput.page(page: fistPageValue)).map {
            switch $0 {
            case .page(let page):
                return page
            case .query(_), .filter(_):
                return fistPageValue
            }
        }).drive(self.fullloading)
        .disposed(by: disposeBag)
        
    }
    
}

extension PaginationViewModel {

    /// Emits items indicating when first page request starts and completes.
    public var firstPageLoading: Driver<Bool> {
        let fistPageValue = (self.paginationRequest as? PaginationRequestTypeSettings)?.firstPageParameterValue ?? Default.firstPageParameterValue
        return fullloading.asDriver().filter { $0.1 == fistPageValue }.map { $0.0 }
    }
    
    /// Emits items to show/hide a empty state view
    public var emptyState: Driver<Bool> {
        return Driver.combineLatest(self.loading.asDriver(onErrorJustReturn: false), self.elements.asDriver()) { (isLoading, elements) -> Bool in
            return !isLoading && elements.isEmpty
        }
        .distinctUntilChanged()
    }
}
