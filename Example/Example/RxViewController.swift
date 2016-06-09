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
    
    lazy var _client: Client = {
        let client = Client(configuration: ClientConfiguration(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"))
        client.observers = [Logger()]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db_name = "app_db_\(arc4random())"
        let client = _client
        
        client.rx_query(Create(Ref.databases, ["name": db_name]))
            .flatMap { _ -> Observable<ValueType> in
                return client.rx_query(Create(Ref.keys, ["database": Ref("databases/blog_db"), "role": "server"]))
            }
            .mapWithField(["secret"])
            .doOnNext { (secret: String) in
                print(secret)
            }
            .doOnError { error in
                //do something with the error
            }
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
}
