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

struct BlogPost {
    let name: String
    let author: String
    let content: String
}


extension BlogPost: FaunaModel {
    
    var value: Value {
        let data = ["name": name, "author": author, "content": content]
        return data.value
    }
}

public protocol FaunaModel: ValueConvertible {

}

class RxViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    lazy var client: Client = {
        let client = Client(configuration: ClientConfiguration(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"))
        client.observers = [Logger()]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSchema(true).flatMap { _ -> Observable<Value> in
            return self.createInstances(true)
        }
        .subscribe()
        .addDisposableTo(disposeBag)
    }
    
}

extension RxViewController{
    
    func setUpSchema(setUp: Bool) -> Observable<Value> {
        if setUp {
            let db_name = "app_db_\(arc4random())"
            return client.rx_query(Create(ref: Ref.databases, params: ["name": db_name]))
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
        }
        return Observable.just(Null())
    }
    
    func createInstances(create: Bool) -> Observable<Value> {
        
        if (create){
            return self.client.rx_query(
                (1...100).map { int in
                    return BlogPost(name: "Blog Post \(int.value)", author: "Martin B",  content: "content")
                    }.mapFauna { blogValue in
                        Create(ref: "classes/posts", params: ["data": blogValue])
                })
        }
        return Observable.just(Null())
    }
}


