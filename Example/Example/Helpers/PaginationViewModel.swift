import Foundation
import RxSwift
import RxCocoa
import FaunaDB

public protocol PaginateType {
    associatedtype Element: DecodableValue
    var match: Expr { get }
    var cursor: Cursor? { get }
    
    init(match: Expr, cursor: Cursor?)
}

public struct Paginate<T: DecodableValue where T.DecodedType == T>: PaginateType {
    public typealias Element = T
    public var match: Expr {
        didSet { cursor = nil }
    }
    public var cursor: Cursor?
    
    public init(match: Expr, cursor: Cursor?){
        self.match = match
        self.cursor = cursor
    }
}


public protocol PaginationResponseType {
    
    associatedtype Paginate: PaginateType

    var elements: [Paginate.Element] { get }
    var previousPage: Cursor? { get }
    var nextPage: Cursor? { get }
    var paginate: Paginate { get }
    
    init(elements: [Paginate.Element], previousPage: Cursor?, nextPage: Cursor?, paginate: Paginate)
}

extension PaginationResponseType {
    
    /// indicates if there are any items in a previous page.
    public var hasPreviousPage: Bool {
        return previousPage != nil
    }
    
    /// indicates if the server has more items that can be fetched using the `nextPage` value.
    public var hasNextPage: Bool {
        return nextPage != nil
    }
}

public struct PaginationResponse<E: DecodableValue where E.DecodedType == E>: PaginationResponseType {
    
    public let elements: [E]
    public let previousPage: Cursor?
    public let nextPage: Cursor?
    public let paginate: Paginate<E>
    
    public init(elements: [E], previousPage: Cursor?, nextPage: Cursor?, paginate: Paginate<E>){
        self.elements = elements
        self.previousPage = previousPage
        self.nextPage = nextPage
        self.paginate = paginate
    }
}


public protocol PaginationRequestType {
    
    associatedtype Response: PaginationResponseType
    
    var paginate: Response.Paginate { get }
    
    init(paginate: Response.Paginate)
    
    func paginateWithMatch(match: Expr) -> Self
    func paginateWithCursor(Cursor: Cursor) -> Self
}

public struct PaginationRequest<E: DecodableValue where E.DecodedType == E>: PaginationRequestType {
    
    public typealias Response = PaginationResponse<E>
    
    public var paginate: Paginate<E>
    
    
    public init(paginate: Paginate<E>) {
        self.paginate = paginate
    }
}

extension PaginationRequestType where Response.Paginate.Element: DecodableValue, Response.Paginate.Element.DecodedType == Response.Paginate.Element{
    
    /**
     Returns an `Observable` of [Response] for the PaginationRequestType instance. If something goes wrong a Error error is propagated through the result sequence.
     
     - returns: An instance of `Observable<Response>`
     */
    public func rx_response() -> Observable<Response> {
        let myPage = paginate
        return Map(collection: FaunaDB.Paginate(resource: paginate.match,
                                                  cursor: paginate.cursor),
                       lambda: Lambda(){ expr in
                            Get(ref: expr)
                        })
            
                .rx_query()
            .flatMap { value -> Observable<Response> in
                let data:Arr = try! value.get(path: "data")
                var cursorData: Arr? = value.get(path: "after")
                let nextCursor = cursorData.map { Cursor.After(expr: $0)}
                cursorData = value.get(path: "before")
                let beforeCursor = cursorData.map { Cursor.Before(expr: $0)}
                
                let elements: [Response.Paginate.Element] = data.map { rawData in
                    let obj: Obj = try! rawData.get(path: "data")
                    return Response.Paginate.Element.decode(obj)!
                }
                return Observable.just(Response.init(elements: elements, previousPage: beforeCursor, nextPage: nextCursor, paginate: myPage))
            }
        }
    
    public func paginateWithMatch(match: Expr) -> Self {
        let newPaginate = Self.Response.Paginate.init(match: match, cursor: self.paginate.cursor)
        return Self.init(paginate: newPaginate)
    }
    
    public func paginateWithCursor(cursor: Cursor) -> Self {
        let newPaginate = Self.Response.Paginate.init(match: self.paginate.match, cursor: cursor)
        return Self.init(paginate: newPaginate)
    }
}


/// Reactive View Model helper to load list of DecodableValue items.
public class PaginationViewModel<PaginationRequest: PaginationRequestType where PaginationRequest.Response.Paginate.Element: DecodableValue, PaginationRequest.Response.Paginate.Element.DecodedType == PaginationRequest.Response.Paginate.Element> {
    
    /// pagination request
    var paginationRequest: PaginationRequest
    public typealias LoadingType = (Bool, Cursor?)
    
    /// trigger a refresh, if emited item is true it will cancel pending request and make a new one. if false it will not refresh if there is a request in progress.
    public let refreshTrigger = PublishSubject<Void>()
    
    public let pullToRefreshTrigger = PublishSubject<Void>()
    /// trigger a next page load, it makes a new request for the nextPage value provided by lastest request sent to server.
    public let loadNextPageTrigger = PublishSubject<Void>()
    /// Cancel any in progress request and start a new one using the filter parameters provided.
    public let matchTrigger = PublishSubject<Expr>()
    
    /// Allows subscribers to get notified about networking errors
    public let errors = PublishSubject<Error>()
    /// Indicates if there is a next page to load. hasNextPage value is the result of getting next link relation from latest response.
    public let hasNextPage = Variable<Bool>(false)
    /// Indicates is there is a request in progress and what is the request page.
    public let fullloading = Variable<LoadingType>((false, nil))
    /// Elements array from first page up to latest fetched page.
    public let elements = Variable<[PaginationRequest.Response.Paginate.Element]>([])
    
    private var disposeBag = DisposeBag()
    private let queryDisposeBag = DisposeBag()
    
    /**
     Initialize a new PaginationViewModel instance.
     
     - parameter paginationRequest: pagination request.
     
     - returns: A PaginationViewModel instance.
     */
    public init(paginationRequest: PaginationRequest) {
        self.paginationRequest = paginationRequest
        bindPaginationRequest(self.paginationRequest, nextPageCursor: nil)
        setUpForceRefresh()
    }
    
    private func setUpForceRefresh() {
        
        matchTrigger
            .doOnNext { [weak self] match in
                guard let mySelf = self else { return }
                let paginationRequest = mySelf.paginationRequest.paginateWithMatch(match)
                mySelf.bindPaginationRequest(paginationRequest, nextPageCursor: nil)
            }
            .map { _ in () }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
        
        pullToRefreshTrigger
            .doOnNext { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest.paginateWithMatch(mySelf.paginationRequest.paginate.match), nextPageCursor: nil)
            }
            .map { _ in () }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
    }
    
    private func bindPaginationRequest(paginationRequest: PaginationRequest, nextPageCursor: Cursor?) {
        disposeBag = DisposeBag()
        self.paginationRequest = paginationRequest

        let refreshRequest = refreshTrigger
            .take(1)
            .flatMap { _ in
                Observable.of(self.paginationRequest)
            }
        
        let nextPageRequest = loadNextPageTrigger
            .take(1)
            .flatMap { nextPageCursor.map { Observable.of(self.paginationRequest.paginateWithCursor($0)) } ?? Observable.empty() }
        
        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)
        
        let response = request
            .flatMap {
                $0.rx_response()
            }
            .shareReplay(1)
        
        Observable
            .of(
                request.map { (true, $0.paginate.cursor) },
                response.map { (false, $0.paginate.cursor) }.catchErrorJustReturn((false, fullloading.value.1))
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
            .doOnError { [weak self] error in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest, nextPageCursor: mySelf.fullloading.value.1) 
            }
            .subscribeNext { [weak self] (paginationResponse: PaginationRequest.Response) in
                guard let mySelf = self else { return }
                let paginationRequest2 = mySelf.paginationRequest
                mySelf.bindPaginationRequest(paginationRequest2, nextPageCursor: paginationResponse.nextPage)
            }
            .addDisposableTo(disposeBag)
    }
}

extension PaginationViewModel {
    
    /// Emits items indicating when start and complete requests.
    public var loading: Driver<Bool> {
        return fullloading.asDriver().map { $0.0 }.distinctUntilChanged()
    }
    
    /// Emits items indicating when first page request starts and completes.
    public var firstPageLoading: Driver<Bool> {
        return fullloading.asDriver().filter { $0.1 == nil }.map { $0.0 }
    }
    
    /// Emits items to show/hide a empty state view
    public var emptyState: Driver<Bool> {
        return Driver.combineLatest(loading, elements.asDriver()) { (isLoading, elements) -> Bool in
            return !isLoading && elements.isEmpty
            }
            .distinctUntilChanged()
    }
}



extension UIControl {
    
    /// Reactive wrapper for UIControlEvents.ValueChanged target action pattern.
    public var rx_valueChanged: ControlEvent<Void> {
        return rx_controlEvent(.ValueChanged)
    }
}

extension UIScrollView {
    
    /// Reactive observable that emit items whenever scroll view contentOffset.y is close to contentSize.height
    public var rx_reachedBottom: Observable<Void> {
        return rx_contentOffset
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just() : Observable.empty()
        }
    }
}