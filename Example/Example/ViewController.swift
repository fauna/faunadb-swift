//
//  ViewController.swift
//  Example
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import UIKit
import FaunaDB
import Result

class ViewController: UIViewController {

    lazy var client: Client = {
        let client = Client(configuration: ClientConfiguration(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"))
        client.observers = [Logger()]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db_name = "app_db_\(arc4random())"
        client.query(Create(Ref.databases,  ["name": db_name])) { [weak self] (result) in
            switch result {
            case .Success:
                self?.client.query(Create(Ref.keys, ["database": Ref("databases/\(db_name)"),
                    "role": "server"])) { (result) in
                        switch result {
                        case .Success(let value):
                            let secret: String = try! value.get("secret")
                            self?.client = Client(configuration: ClientConfiguration(secret: secret))
                            
//                            let arr: Arr = ["First post", "Second Post", "Third Post"]
//                            self?.client.query(arr.mapFauna { Create("classes/posts", ["data": Obj(("title", $0))]) })
                            var ecoString: String?
                            self?.client.query("ayz") { result in
                                let responseValue = try! result.dematerialize() as! String
                                ecoString = responseValue
                            }
                        case .Failure(_):
                            break
                        }
                }
            case .Failure(_):
                break
            }
        }
    }
}


