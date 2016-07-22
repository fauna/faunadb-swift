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
        faunaClient = Client(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI", observers: [Logger()])
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
                    return self.rxCreateInstances()
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
        return Create(ref: Ref("databases"), params: ["name": dbName]).rx_query()
            .flatMap { _ in
                return Create(ref: Ref("keys"), params: ["database": Ref("databases/\(dbName)"), "role": "server"]).rx_query()
            }
            .mapWithField("secret")
            .doOnNext { (secret: String) in
                faunaClient = Client(secret: secret, observers: [Logger()])
            }
            .flatMap { _ in
                return Create(ref: Ref("classes"), params: ["name": "posts"]).rx_query()
            }
            .flatMap { _ in
                return Do(exprs: Create(ref: Ref("indexes"), params: ["name": "posts_by_tags",
                                        "source": BlogPost.classRef,
                                        "terms": Arr([Obj(["field": Arr(["data", "tags"])])]),
                                        "values": Arr()]),
                                  Create(ref: Ref("indexes"), params: ["name": "posts_by_name",
                                        "source": BlogPost.classRef,
                                        "terms": Arr([Obj(["field": Arr(["data", "name"])])]),
                                        "values": Arr()])
                        ).rx_query()
            }
    }
    
    func rxCreateInstances() -> Observable<Value> {
        return (1...100).map {
            BlogPost(name: "Blog Post \($0)", author: "FaunaDB",  content: "content", tags: $0 % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
        }.mapFauna { blogValue in
            Create(ref: Ref("classes/posts"), params: ["data": blogValue.value])
        }.rx_query()
    }
 }
 
 
extension SetUpFaunaController{
 
    //MARK: Standalone schema set up
    
    
    func setUpSchema(dbName: String, callback: (Result<Value, Error> -> ())) {
        faunaClient.query(Create(ref: Ref("databases"), params: ["name": dbName])) { createDbR in
            
            faunaClient.query(Create(ref: Ref("keys"), params: ["database": Ref("databases/\(dbName)"), "role": "server"])) { createKeyR in
                guard let result = try? createKeyR.dematerialize() else {
                    callback(createKeyR)
                    return
                }
                let secret: String = try! result.get(path: "secret")
                faunaClient = Client(secret: secret, observers: [Logger()])
                faunaClient.query(Create(ref: Ref("classes"), params: ["name": "posts"])) { createClassR in
                    guard let _ = try? createClassR.dematerialize() else {
                        callback(createClassR)
                        return
                    }
                    faunaClient.query({
                        return Do(exprs: Create(ref: Ref("indexes"), params: [ "name": "posts_by_tags",
                                                                        "source": BlogPost.classRef,
                                                                        "terms": Arr(Obj(["field": Arr(["data", "tags"])])),
                                                                        "values": Arr()]),
                                         Create(ref: Ref("indexes"), params: [ "name": "posts_by_name",
                                                                        "source": BlogPost.classRef,
                                            "terms": Arr(Obj(["field": Arr(["data", "name"]),
                                                              "transform": "casefold"])),
                                            "values": Arr()])
                               )
                    }()) {  createIndexR in
                        callback(createIndexR)
                    }
                }
            }
        }
    }
    
    func createInstances(callback: (Result<Value, Error> -> ())) {
        faunaClient.query({
            (1...100).map { int in
                return BlogPost(name: "Blog Post \(int)", author: "FaunaDB",  content: "content", tags: int % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
                }.mapFauna { blogValue in
                    Create(ref: Ref("classes/posts"), params: ["data": blogValue.value])
                }
        }()) { result in
            callback(result)
        }
    }
}



