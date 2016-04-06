//
//  DataProvider.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import RxCocoa

class PaginationViewModel<Element: XLDecodable> {
    
    var paginationRequest: PaginationRequest<Element>
    typealias LoadingType = (Bool, String)
    
    let refreshTrigger = PublishSubject<Bool>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let queryTrigger = PublishSubject<String>()
    let filterTrigger = PublishSubject<FilterType>()
    let networkErrorTrigger = PublishSubject<NetworkError>()
    
    let queryPending = Variable<Bool>(false)
    let hasNextPage = Variable<Bool>(false)
    let fullloading = Variable<LoadingType>((false, "1"))
    let elements = Variable<[Element]>([])
    
    private var disposeBag = DisposeBag()
    private let queryDisposeBag = DisposeBag()
    
    init(paginationRequest: PaginationRequest<Element>) {
        self.paginationRequest = paginationRequest
        bindPaginationRequest(self.paginationRequest, nextPage: nil)
        setUpForceRefresh()
    }
    
    private func setUpForceRefresh() {
        
        queryTrigger
            .doOnNext { [weak self] _ in self?.queryPending.value = true }
            .throttle(0.25, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .doOnNext { [weak self] queryString in
                guard let mySelf = self else { return }
                mySelf.queryPending.value = false
                mySelf.bindPaginationRequest(mySelf.paginationRequest.routeWithQuery(queryString), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
        
        refreshTrigger
            .filter { $0 }
            .doOnNext { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest.routeWithPage("1"), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
        
        
        filterTrigger
            .doOnNext { [weak self] fitler in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest.routeWithFilter(fitler), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
    }
    
    private func bindPaginationRequest(paginationRequest: PaginationRequest<Element>, nextPage: String?) {
        disposeBag = DisposeBag()
        self.paginationRequest = paginationRequest
        let refreshRequest = refreshTrigger
            .filter { !$0 }
            .take(1)
            .map { _ in paginationRequest }
        
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
                response.map { (false, $0.page ?? "1") }.catchErrorJustReturn((false, fullloading.value.1))
            )
            .merge()
            .bindTo(fullloading)
            .addDisposableTo(disposeBag)
                
        Observable
            .combineLatest(elements.asObservable(), response) { elements, response in
                return response.hasPreviousPage ? elements + response.elements : response.elements
            }
            .take(1)
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)
        
        response
            .doOnNetworkError { [weak self] error throws in
                guard let mySelf = self else { return }
                Observable.just(error).bindTo(mySelf.networkErrorTrigger).addDisposableTo(mySelf.disposeBag)
            }
            .doOnError { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest, nextPage: mySelf.fullloading.value.1) }
            .subscribeNext { [weak self] paginationResponse in
                self?.bindPaginationRequest(paginationRequest, nextPage: paginationResponse.nextPage)
            }
            .addDisposableTo(disposeBag)
    }
}

extension PaginationViewModel {
    
    var loading: Driver<Bool> {
        return fullloading.asDriver().skip(1).map { $0.0 }.distinctUntilChanged()
    }
    
    var firstPageLoading: Driver<Bool> {
        return fullloading.asDriver().filter { $0.1 == "1" }.map { $0.0 }
    }
    
    var emptyState: Driver<Bool> {
        return Driver.combineLatest(loading, elements.asDriver().skip(1)) { (isLoading, elements) -> Bool in
            return !isLoading && elements.isEmpty
        }
        .distinctUntilChanged()
    }
    
}
