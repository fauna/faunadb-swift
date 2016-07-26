//
//  ViewController.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
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
    var cursor: Cursor?
    
    var predicateExpr: Expr {
        let match: Expr = {
            if let text = searchBar.text where text.isEmpty == false {
                return Intersection(sets: Match(index: Ref("indexes/posts_by_tags"), terms: segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel"),
                                    Match(index: Ref("indexes/posts_by_name"), terms: text))
            }
            return Match(index: Ref("indexes/posts_by_tags"), terms: segmentedControl.selectedSegmentIndex == 1 ? "philosophy" : "travel")
        }()
        return Map(collection: FaunaDB.Paginate(resource: match, cursor: cursor)) { ref in
            Get(ref: ref)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.addTarget(self, action: #selector(StandaloneViewController.segmentedConteolChanged), forControlEvents: UIControlEvents.ValueChanged)
        searchBar.delegate = self
        //tableView.delegate = self
        tableView.dataSource = self
        performQuery()
    }
    func segmentedConteolChanged() {
        print(segmentedControl.selectedSegmentIndex)
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
        print(searchBar.text)
    }
}


extension StandaloneViewController {
    
    private func showAlertMessage(error: FaunaDB.Error){
        let alert = UIAlertController(title: "Oops!", message:"Something went wrong.. Please try again!!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        self.presentViewController(alert, animated: true){}
    }
    
    func performQuery() -> NSURLSessionDataTask {
        return faunaClient.query(predicateExpr) { [weak self] result in
            switch result {
            case .Failure(let error):
                self?.showAlertMessage(error)
            case .Success(let value):
                let data: [BlogPost] = try! value.get(path: "data")
                var cursorData: Arr? = value.get(path: "after")
                self?.cursor = cursorData.map { Cursor.After(expr: $0)}
                cursorData = value.get(path: "before")
                let beforeCursor = cursorData.map { Cursor.Before(expr: $0)}
                if let _ = beforeCursor {
                    self?.items.appendContentsOf(data)
                }
                else {
                    self?.items = data
                }
            }
        }
    }
}






