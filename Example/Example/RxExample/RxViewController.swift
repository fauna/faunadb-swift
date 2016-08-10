//
//  RxViewController.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
import UIKit
import FaunaDB
import RxSwift
import RxCocoa

class RxViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var editButton: UIBarButtonItem!
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


    override func viewDidLoad(){

        super.viewDidLoad()
        let refreshControl = self.refreshControl

        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .OnDrag
        tableView.addSubview(refreshControl)
        tableView.delegate = self
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
                return refreshControl.refreshing
            }
            .bindTo(viewModel.pullToRefreshTrigger)
            .addDisposableTo(disposeBag)



        viewModel.loading
            .filter { !$0 && refreshControl.refreshing }
            .driveNext { _ in
                refreshControl.endRefreshing()
            }
            .addDisposableTo(disposeBag)

        viewModel.emptyState
            .driveNext { [weak self] emptyState in self?.emptyStateLabel.hidden = !emptyState }
            .addDisposableTo(disposeBag)


        tableView
        .rx_itemDeleted
            .flatMap { [weak self] (indexPath: NSIndexPath) -> Observable<Value> in
            var elements = self?.viewModel.elements.value ?? []
            let blogpost = elements.removeAtIndex(indexPath.row)
            Observable.just(elements).bindTo(self!.viewModel.elements).addDisposableTo(self!.disposeBag)
            return blogpost.fDelete()!.rx_query()
        }
        .subscribeNext { (value: Value) in }
        .addDisposableTo(disposeBag)

        editButton
        .rx_tap
        .subscribeNext { [weak self] in
            let newEditingValue = !(self?.tableView.editing ?? false)
            self?.tableView.setEditing(newEditingValue, animated: true)
            self?.editButton.title = newEditingValue ? "Edit" : "Done"
        }
        .addDisposableTo(disposeBag)
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

}
