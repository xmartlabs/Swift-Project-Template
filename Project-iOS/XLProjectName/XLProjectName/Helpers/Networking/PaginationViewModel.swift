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
import RxCocoa

class PaginationViewModel<Element: Decodable where Element.DecodedType == Element> {
    
    var request: PaginationRequest<Element>
    typealias LoadingType = (Bool, String)
    
    let refreshTrigger = PublishSubject<Bool>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let queryTrigger = PublishSubject<String>()
    let networkErrorTrigger = PublishSubject<NetworkError>()

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
        queryTrigger.skip(1)
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
            .doOnNetworkError { [weak self] error throws in
                guard let mySelf = self else { return }
                Observable.just(error).bindTo(mySelf.networkErrorTrigger).addDisposableTo(mySelf.disposeBag)
            }
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
