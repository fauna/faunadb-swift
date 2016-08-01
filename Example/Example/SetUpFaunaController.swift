 //
//  ViewController.swift
//  Example
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import UIKit
import FaunaDB
import Result
import RxSwift

class SetUpFaunaController: UITableViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        #if DEBUG
        faunaClient = Client(secret: secret, observers: [Logger()])
        #else
        faunaClient = Client(secret: secret)
        #endif
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // animate activity indicator, disable UI interaction
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let indicators = cell?.contentView.subviews.filter { $0 is UIActivityIndicatorView }.map { $0 as! UIActivityIndicatorView }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.view.userInteractionEnabled = false
        indicators?.forEach { $0.startAnimating() }

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // Standalone setup
                let db_name = "app_db_\(arc4random())"
                setUpSchema(db_name) { [weak self] result in
                    guard let _ = try? result.dematerialize() else {
                        indicators?.forEach { $0.stopAnimating()}
                        self?.view.userInteractionEnabled = true
                        return /* handle error */
                    }
                    self?.createInstances { createInstancesR in
                        indicators?.forEach { $0.stopAnimating()}
                        self?.view.userInteractionEnabled = true
                        guard let _ = try? createInstancesR.dematerialize() else { return /* handle error */ }
                        self?.performSegueWithIdentifier("standaloneAfterSetupSegue", sender: self)
                    }
                }
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // Rx setup
                let db_name = "app_db_\(arc4random())"
                rxSetUpSchema(db_name).flatMap { _ in 
                    self.rxCreateInstances()
                }
                .doOnCompleted { [weak self] in
                    indicators?.forEach { $0.stopAnimating()}
                    self?.view.userInteractionEnabled = true
                }
                .subscribeNext { [weak self] _ in
                    self?.performSegueWithIdentifier("rxAfterSetupSegue", sender: self)
                }
                .addDisposableTo(disposeBag)
            }
        }
    }

    let disposeBag = DisposeBag()
}


 extension SetUpFaunaController{

    func rxSetUpSchema(dbName: String) -> Observable<Value> {

        //MARK: Rx schema set up
        return faunaClient.rx_query(Create(ref: Ref("databases"), params: Obj(["name": dbName])))
            .flatMap { _ in
                return faunaClient.rx_query(Create(ref: Ref("keys"), params: Obj(["database": Ref("databases/\(dbName)"), "role": "server"])))
            }
            .mapWithField("secret")
            .doOnNext { (secret: String) in
                #if DEBUG
                faunaClient = Client(secret: secret, observers: [Logger()])
                #else
                faunaClient = Client(secret: secret)
                #endif
            }
            .flatMap { _ in
                return faunaClient.rx_query(Create(ref: Ref("classes"), params: Obj(["name": "posts"])))
            }
            .flatMap { _ in
                return faunaClient.rx_query(
                        Do(exprs: Create(ref: Ref("indexes"), params: ["name": "posts_by_tags",
                                        "source": BlogPost.classRef,
                                        "terms": Arr(Obj(["field": Arr("data", "tags")])),
                                        "values": Arr()] as Obj),
                                  Create(ref: Ref("indexes"), params: ["name": "posts_by_name",
                                        "source": BlogPost.classRef,
                                        "terms": Arr(Obj(["field": Arr("data", "name")])),
                                        "values": Arr()] as Obj)
                        ))
            }
    }

    func rxCreateInstances() -> Observable<Value> {
        let blogPosts = (1...100).map {
            BlogPost(name: "Blog Post \($0)", author: "FaunaDB",  content: "content", tags: $0 % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
        }
        return faunaClient.rx_query(
                        Map(collection: Arr(blogPosts)) { blogPost  in
                            Create(ref: Ref("classes/posts"), params: Obj(["data": blogPost]))
                        })
    }
 }


extension SetUpFaunaController{

    //MARK: Standalone schema set up

    func setUpSchema(dbName: String, callback: (Result<Value, Error> -> ())) {
        faunaClient.query(Create(ref: Ref("databases"), params: Obj(["name": dbName]))) { createDbR in

            faunaClient.query(Create(ref: Ref("keys"), params: Obj(["database": Ref("databases/\(dbName)"), "role": "server"]))) { createKeyR in
                guard let result = try? createKeyR.dematerialize() else {
                    callback(createKeyR)
                    return
                }
                let secret: String = try! result.get(path: "secret")
                #if DEBUG
                faunaClient = Client(secret: secret, observers: [Logger()])
                #else
                faunaClient = Client(secret: secret)
                #endif
                faunaClient.query(Create(ref: Ref("classes"), params: Obj(["name": "posts"]))) { createClassR in
                    guard let _ = try? createClassR.dematerialize() else {
                        callback(createClassR)
                        return
                    }
                    faunaClient.query(
                        Do(exprs:
                                        Create(ref: Ref("indexes"), params:["name": "posts_by_tags",
                                                                            "source": BlogPost.classRef,
                                                                            "terms": Arr(Obj(["field": Arr("data", "tags")])),
                                                                            "values": Arr()] as Obj),
                                        Create(ref: Ref("indexes"), params:["name": "posts_by_name",
                                                                            "source": BlogPost.classRef,
                                                                            "terms": Arr(Obj(["field": Arr("data", "name")])),
                                                                            "values": Arr()] as Obj)
                               )
                    , completion: callback)
                }
            }
        }
    }

    func createInstances(callback: (Result<Value, Error> -> ())) {
        faunaClient.query({
            let blogPosts = (1...100).map {
                BlogPost(name: "Blog Post \($0)", author: "FaunaDB",  content: "content", tags: $0 % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
            }
            return Map(collection: Arr(blogPosts)) { blogPost  in
                 Create(ref: Ref("classes/posts"), params: Obj(["data": blogPost]))
            }
        }(), completion: callback)
    }
}
