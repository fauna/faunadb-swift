//
//  ViewController.swift
//  Example
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import UIKit
import FaunaDB

class ViewController: UIViewController {

    lazy var client: Client = {
        let client = Client(configuration: ClientConfiguration(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"))
        client.observers = [Logger()]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let db_name = "app_db_\(arc4random())"
        client.query(Create(Ref.databases,  ["name": db_name])) { [weak self] (result) in
            switch result {
            case .Success(let _):
                self?.client.query(Create(Ref.keys, ["database": Ref("databases/\(db_name)"),
                    "role": "server"])) { (result) in
                }
            case .Failure(let error):
                break
            }
        }
        
        
        
        // use the new key
        
//        client.query({ () -> ExprType in
//            Create(Ref.classes, ["name": "posts"])
//        }, completionHandler: { (result) in
//            
//        })
    }

}

