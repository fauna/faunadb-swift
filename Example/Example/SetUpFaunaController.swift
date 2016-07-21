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

 
class SetUpFaunaController: UIViewController {

    let disposeBag = DisposeBag()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBAction func onTap(sender: UIButton) {
        sender.enabled = false
        activityIndicatorView.startAnimating()
        let db_name = "app_db_\(arc4random())"
        setUpSchema(true, dbName: db_name).flatMap { _ in
            return self.createInstances(true)
            }
            .subscribeNext({ [weak self] _ in
                sender.enabled = true
                self?.activityIndicatorView.stopAnimating()
                self?.performSegueWithIdentifier("afterSetupSegue", sender: self)
                })
            .addDisposableTo(disposeBag)
    }
}
 
 
 extension SetUpFaunaController{
    
    func setUpSchema(createDB: Bool = false, dbName: String = "app_db_120822737") -> Observable<Value> {
        if createDB {
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
                    return Create(ref: Ref("indexes"), params: ["name": "posts_by_tags_with_title",
                        "source": BlogPost.classRef,
                        "terms": [["field": Arr(["data", "tags"])] as Obj] as Arr,
                        "values": [] as Arr
                        ]).rx_query()
            }
        }
        return Create(ref: Ref("keys"), params: ["database": Ref("databases/\(dbName)"), "role": "server"]).rx_query()
            .mapWithField(["secret"])
            .doOnNext { (secret: String) in
                faunaClient = Client(secret: secret)
            }
            .map { $0 as Value}
    }
    
    func createInstances(create: Bool) -> Observable<Value> {
        if (create){
            return
                (1...100).map { int in
                    return BlogPost(name: "Blog Post \(int)", author: "FaunaDB",  content: "content", tags: int % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
                    }.mapFauna { blogValue in
                        Create(ref: Ref("classes/posts"), params: ["data": blogValue.value])
                    }.rx_query()
        }
        return Observable.just(Null())
    }
 }

 //class ViewController: UIViewController {
 //
 //    lazy var client: Client = {
 //        let client = Client(configuration: ClientConfiguration(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"))
 //        client.observers = [Logger()]
 //        return client
 //    }()
 //
 //    override func viewDidLoad() {
 //        super.viewDidLoad()
 //
 //        let db_name = "app_db_\(arc4random())"
 //        client.query(Create(ref: Ref("databases"),  params: ["name": db_name])) { [weak self] (result) in
 //            switch result {
 //            case .Success:
 //                self?.client.query(Create(ref: Ref("keys"), params: ["database": Ref("databases/\(db_name)"),
 //                    "role": "server"])) { (result) in
 //                        switch result {
 //                        case .Success(let value):
 //                            let secret: String = try! value.get("secret")
 //                            self?.client = Client(configuration: ClientConfiguration(secret: secret))
 //
 ////                            let arr: Arr = ["First post", "Second Post", "Third Post"]
 ////                            self?.client.query(arr.mapFauna { Create("classes/posts", ["data": Obj(("title", $0))]) })
 //                            var ecoString: String?
 //                            self?.client.query("ayz") { result in
 //                                let responseValue = try! result.dematerialize() as! String
 //                                ecoString = responseValue
 //                            }
 //                        case .Failure(_):
 //                            break
 //                        }
 //                }
 //            case .Failure(_):
 //                break
 //            }
 //        }
 //    }
 //}


