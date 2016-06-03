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
        let clientConf = ClientConfiguration(secret: "")
        let client = Client(configuration: clientConf)
        client.observers = [Logger()]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        client.query(Create(Ref.databases,  ["name": "blog_db"])) { (result) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

