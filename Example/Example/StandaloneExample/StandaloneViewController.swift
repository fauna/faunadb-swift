//
//  ViewController.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
import UIKit
import FaunaDB

class StandaloneViewController: UIViewController {

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

    var items = [BlogPost]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var lastPageRetrieved: PaginationResult<BlogPost>?
    var pendingRequest: NSURLSessionDataTask?

    var predicateExpr: Expr {
        let match: Expr = {
            if let text = searchBar.text where text.isEmpty == false {
                return Intersection(sets: Match(index: Ref("indexes/posts_by_tags"), terms: segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel"),
                                    Match(index: Ref("indexes/posts_by_name"), terms: text))
            }
            return Match(index: Ref("indexes/posts_by_tags"), terms: segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel")
        }()
        return Map(collection: FaunaDB.Paginate(resource: match, cursor: lastPageRetrieved?.afterCursor)) { ref in
            Get(ref: ref)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.addTarget(self, action: #selector(StandaloneViewController.segmentedControlChanged), forControlEvents: .ValueChanged)
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(StandaloneViewController.refreshControlChanged), forControlEvents: .ValueChanged)
        editButton.target = self
        editButton.action = #selector(StandaloneViewController.editControllerTapped)
        performQuery(cancelPendingRequest: true, backToFirstPage: true) { _ in }
    }
}

extension StandaloneViewController {

    //MARK: Events

    func segmentedControlChanged() {
        performQuery(cancelPendingRequest: true, backToFirstPage: true) { _ in }
    }

    func refreshControlChanged() {
        guard refreshControl.refreshing  else { return }
        performQuery(cancelPendingRequest: true, backToFirstPage: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    func editControllerTapped() {
        tableView.setEditing(!(tableView.editing ?? false), animated: true)
        editButton.title = tableView.editing ? "Edit" : "Done"
    }
}

extension StandaloneViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        let blogPost = items[indexPath.row]
        cell.textLabel?.text = blogPost.name
        cell.detailTextLabel?.text = "\(blogPost.tags.joinWithSeparator(", ")) - \(blogPost.author)"
        return cell
    }
}

extension StandaloneViewController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        performQuery(cancelPendingRequest: true, backToFirstPage: true) { _ in }
    }
}

extension StandaloneViewController: UITableViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView){
        let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let y = scrollView.contentOffset.y + scrollView.contentInset.top
        let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
        let reachedBottom = y > threshold
        if reachedBottom {
            performQuery(cancelPendingRequest: false, backToFirstPage: false, callback: { _ in })
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard editingStyle == .Delete else { return }
        let blogPost = items[indexPath.row]

        faunaClient.query(Delete(ref: blogPost.refId!)) { [weak self] result in
            if let index = self?.items.indexOf(blogPost) where result.error == nil {
                self?.items.removeAtIndex(index)
            }
        }
    }
}


extension StandaloneViewController {

    private func showAlertMessage(error: Error){
        if case .NetworkException(_, _, _) = error{
            return
        }
        let alert = UIAlertController(title: "Oops!", message:"Something went wrong.. Please try again!!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default) { _ in })
        self.presentViewController(alert, animated: true){}
    }

    func performQuery(cancelPendingRequest cancelPendingRequest: Bool, backToFirstPage: Bool, callback: ((data: Value?, error: Error?) -> ())) -> NSURLSessionDataTask? {
        guard pendingRequest == nil || cancelPendingRequest else {
            callback(data: nil, error: nil)
            return nil
        }
        if cancelPendingRequest {
            pendingRequest?.cancel()
        }
        if backToFirstPage {
            lastPageRetrieved = nil
            items = []
        }
        activityIndicator.startAnimating()
        pendingRequest = faunaClient.query(predicateExpr) { [weak self] result in
            self?.activityIndicator.stopAnimating()
            self?.pendingRequest = nil
            switch result {
            case .Failure(let error):
                self?.showAlertMessage(error)
                callback(data: nil, error: error)
            case .Success(let value):
                let paginationData: PaginationResult<BlogPost> = try! value.get()
                self?.lastPageRetrieved = paginationData
                if let _ = paginationData.beforeCursor {
                    self?.items.appendContentsOf(paginationData.items)
                }
                else {
                    self?.items = paginationData.items
                }
                callback(data: value, error: nil)
            }
        }
        return pendingRequest
    }
}


struct PaginationResult<T: DecodableValue where T.DecodedType == T>: DecodableValue {
    let items: [T]
    let afterCursor: Cursor?
    let beforeCursor: Cursor?
    
    init(items: [T], afterCursor: Cursor? = nil, beforeCursor: Cursor? = nil){
        self.items = items
        self.afterCursor = afterCursor
        self.beforeCursor = beforeCursor
    }
    
    static func decode(value: Value) -> PaginationResult<T>? {
        let afterCursorData: Arr? = value.get(path: "after")
        let beforeCursorData: Arr? = value.get(path: "before")
        return try? self.init(      items: value.get(path: "data"),
                                    afterCursor: afterCursorData.map { Cursor.After(expr: $0)},
                                    beforeCursor: beforeCursorData.map { Cursor.Before(expr: $0)})
    }
}
