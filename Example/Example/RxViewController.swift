//
//  RxViewController.swift
//  Example
//
//  Created by Martin Barreto on 6/9/16.
//
//

import Foundation
import FaunaDB
import RxFaunaDB
import RxSwift
import RxCocoa


var faunaClient: Client = {
    return Client(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI", observers: [Logger()])
}()



struct BlogPost {
    let name: String
    let author: String
    let content: String
    let tags: [String]
    
    init(name:String, author: String, content: String){
        self.name = name
        self.author = author
        self.content = content
        self.tags = []
    }
    
    init(name:String, author: String, content: String, tags: [String]){
        self.name = name
        self.author = author
        self.content = content
        self.tags = tags
    }
    
    var fId: String?
}

extension BlogPost: FaunaModel {

    
    var value: Value {
        let data: [String: Any] = ["name": name, "author": author, "content": content, "tags": tags]
        return data.value
    }
    
    static var classRef: Ref { return Ref("classes/posts") }
    
    init(data: Obj) {
        // 0 is ts
        self.name = try! data.get("name")
        self.author = try! data.get("author")
        self.content = try! data.get("content")
        let arrTags: Arr? = data.get("tags")
        self.tags = arrTags?.map { $0 as! String } ?? []
    }
}


class RxViewController: UIViewController {
    
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
                                                        match: Match(index: Ref("indexes/posts_by_tags_with_title"), terms: "travel"),
                                                        cursor: nil)))
        }()
    
    override func viewDidLoad() {        
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .OnDrag
        tableView.addSubview(self.refreshControl)
        emptyStateLabel.text = "No blog post found"
        
        
        segmentedControl.rx_valueChanged
            .map { [weak self] in
                return Match(index: Ref("indexes/posts_by_tags_with_title"), terms: self?.segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel") }
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




