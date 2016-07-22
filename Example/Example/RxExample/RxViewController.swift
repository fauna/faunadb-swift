//
//  RxViewController.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//


import Foundation
import FaunaDB
import RxFaunaDB
import RxSwift
import RxCocoa

struct BlogPost {
    let name: String
    let author: String
    let content: String
    let tags: [String]
    
    init(name:String, author: String, content: String, tags: [String] = []){
        self.name = name
        self.author = author
        self.content = content
        self.tags = tags
    }
    
    var fId: String?
}

extension BlogPost: DecodableValue {
    static func decode(value: Value) -> BlogPost? {
        return try? self.init(name: value.get(path: "name"),
                            author: value.get(path: "author"),
                           content: value.get(path: "content"),
                              tags: value.get(path: "tags") ?? [])
    }
}

extension BlogPost: FaunaModel {

    
    var value: Value {
        return Obj(["name": name, "author": author, "content": content, "tags": Arr(tags)])
    }
    
    static var classRef: Ref { return Ref("classes/posts") }
}


class RxViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "No blog posts"
        emptyStateLabel.textAlignment = .Center
        return emptyStateLabel
    }()
    
    let disposeBag = DisposeBag()
    
    lazy var viewModel: PaginationViewModel<PaginationRequest<BlogPost>> = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(paginate: Paginate<BlogPost>(
                                                        match: Match(index: Ref("indexes/posts_by_tags"), terms: "travel"),
                                                        cursor: nil)))
        }()
    
    override func viewDidLoad() {        
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .OnDrag
        tableView.addSubview(self.refreshControl)
        emptyStateLabel.text = "No blog post found"
        
        searchBar.rx_text
            .throttle(0.25, scheduler: MainScheduler.instance)
            .map { [weak self] searchStr in
                if let text = self?.searchBar.text where text.isEmpty == false {
                    return Intersection(sets: Match(index: Ref("indexes/posts_by_tags"), terms: self?.segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel"),
                                              Match(index: Ref("indexes/posts_by_name"), terms: text))
                }
                return Match(index: Ref("indexes/posts_by_tags"), terms: self?.segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel")
            }
            .bindTo(viewModel.matchTrigger)
            .addDisposableTo(disposeBag)
        
        segmentedControl.rx_valueChanged
            .map { [weak self] in
                if let text = self?.searchBar.text where text.isEmpty == false {
                    return Intersection(sets: Match(index: Ref("indexes/posts_by_tags"), terms: self?.segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel"),
                        Match(index: Ref("indexes/posts_by_name"), terms: text))
                }
                return Match(index: Ref("indexes/posts_by_tags"), terms: self?.segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel")
            }
            .bindTo(viewModel.matchTrigger)
            .addDisposableTo(disposeBag)
        
        
        rx_sentMessage(#selector(RxViewController.viewWillAppear(_:)))
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading
            .drive(activityIndicator.rx_animating)
            .addDisposableTo(disposeBag)

        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading) { elements, loading in return loading ? [] : elements }
            .asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, blogPost, cell in
                cell.textLabel?.text = blogPost.name
                cell.detailTextLabel?.text = "\(blogPost.tags.joinWithSeparator(", ")) - \(blogPost.author)"
            }
            .addDisposableTo(disposeBag)
        
        
        
        refreshControl.rx_valueChanged
            .filter {
                return self.refreshControl.refreshing
            }
            .bindTo(viewModel.pullToRefreshTrigger)
            .addDisposableTo(disposeBag)


        
        viewModel.loading
            .filter { !$0 && self.refreshControl.refreshing }
            .driveNext { _ in
                self.refreshControl.endRefreshing()
            }
            .addDisposableTo(disposeBag)

        viewModel.loading
            .filter { !$0 && self.refreshControl.refreshing }
            .driveNext { _ in self.refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)
        
        viewModel.emptyState
            .driveNext { [weak self] emptyState in self?.emptyStateLabel.hidden = !emptyState }
            .addDisposableTo(disposeBag)

    }
    
}




