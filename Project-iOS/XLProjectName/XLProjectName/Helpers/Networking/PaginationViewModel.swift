//
//  DataProvider.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Alamofire
import Foundation
import Argo
import RxSwift

class PaginationViewModel<Element: Decodable where Element.DecodedType == Element> {
    
    var request: PaginationRequest<Element>
    typealias LoadingType = (Bool, String)
    
    let refreshTrigger = PublishSubject<Bool>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let queryTrigger = PublishSubject<String>()

    let hasNextPage = Variable<Bool>(false)
    let fullloading = Variable<LoadingType>((false, "1"))
    let elements = Variable<[Element]>([])
    
    private var disposeBag = DisposeBag()
    private let queryDisposeBag = DisposeBag()
    
    init(route: RequestType, page: String = "1", query: String = "") {
        request = PaginationRequest(route: route, page: page, query: query)
        bindPaginationRequest(request, nextPage: nil)
        setUpForceRefresh()
    }
    
    private func setUpForceRefresh() {
        queryTrigger
            .throttle(0.25, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .doOnNext { [weak self] queryString in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.request.routeWithQuery(queryString), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
        
        refreshTrigger.filter { $0 == true }
            .doOnNext { [weak self] queryString in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.request.routeWithPage("1"), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
    }
    
    private func bindPaginationRequest(paginationRequest: PaginationRequest<Element>, nextPage: String?) {
        disposeBag = DisposeBag()
        
        let refreshRequest = refreshTrigger.filter { $0 == false }
            .take(1)
            .map { _ in paginationRequest.routeWithPage(paginationRequest.page) }
        
        let nextPageRequest = loadNextPageTrigger
            .take(1)
            .flatMap { nextPage.map { Observable.of(paginationRequest.routeWithPage($0)) } ?? Observable.empty() }
        
        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)
        
        let response = request
            .flatMap { $0.rx_collection() }
            .shareReplay(1)
        
        Observable
            .of(
                request.map { (true, $0.page) },
                response.map { (false, $0.page ?? "1") }
            )
            .merge()
            .bindTo(fullloading)
            .addDisposableTo(disposeBag)
                
        Observable
            .combineLatest(elements.asObservable(), response) { elements, response in
                return response.hasPreviousPage
                    ? elements + response.elements
                    : response.elements
            }
            .take(1)
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)
        
        response
            .subscribeNext { [weak self] paginationResponse in
                self?.bindPaginationRequest(paginationRequest, nextPage: paginationResponse.nextPage)
            }
            .addDisposableTo(disposeBag)
    }
}

extension PaginationViewModel {
    
    var loading: Observable<Bool> {
        return fullloading.asObservable().map { $0.0 }
    }
    
    var firstPageLoading: Observable<Bool> {
        return fullloading.asObservable().filter { $0.1 == "1" }.map { $0.0 }
    }
    
    var emptyState: Observable<Bool> {
        return Observable.combineLatest(loading.skip(1), elements.asObservable().map { $0.isEmpty }.skip(1)) { (isLoading, isEmpty) throws in
            return !isLoading && isEmpty
        }
    }
    
}
