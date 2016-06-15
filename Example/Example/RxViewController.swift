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

class RxViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    lazy var client: Client = {
        let client = Client(configuration: ClientConfiguration(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"))
        client.observers = [Logger()]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let db_name = "app_db_\(arc4random())"
        client.rx_query(Create(ref: Ref.databases, params: ["name": db_name] as Obj))
            .flatMap { _ -> Observable<Value> in
                return self.client.rx_query(Create(ref: Ref.keys, params: ["database": Ref("databases/\(db_name)"), "role": "server"]))
            }
            .mapWithField(["secret"])
            .doOnNext { (secret: String) in
                self.client = Client(configuration: ClientConfiguration(secret: secret))
            }
            .flatMap { _ -> Observable<Value> in
                return self.client.rx_query(Create(ref: Ref.classes, params: ["name":"posts"]))
            }
            .flatMap { _ -> Observable<Value> in
                let arr = ["My First post", "My Second Post", "My third post"]
                return self.client.rx_query(
                                            arr
                                            .mapFauna { title in
                                                    Create(ref: "classes/posts", params: ["data": ["title": title] as Obj])
                                            })
            }
            .doOnNext({ value in
                print(value)
            })
            .doOnError { error in
                //do something with the error
                print(error)
            }
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
}
