//
//  Playground.playground
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

//: Playground - noun: a place where people can play

import UIKit
import Foundation


@testable import FaunaDB
import Gloss
import Result

func stringFormat(json: JSON) -> String{
    let jsonData = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
    let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
    return jsonString
}


// ref

let refValue = Ref.databases

String(refValue)


let anotherRefValue: Ref = "databases"


// Null

let nilValue: Null = nil
let anotherNilValue = Null()


// ArrayValue

var array: Arr = [3, "Hola", 3.34, true, Double(3.34), refValue, anotherRefValue, nilValue, anotherNilValue]

let arrayStr = String(array)


array.append("new scalar value")

let nullArray = array.filter { $0 is Null }

String(nullArray)


let arrayOfArray: Arr = [array, array]

String(arrayOfArray)


// ObjectValue

let objectValue: Obj = ["@name": "Hen Wen", "age": 110]
String(objectValue)


let objectValue2: Obj = ["@obj": objectValue]
String(objectValue2)


let clientConf = ClientConfiguration(secret: "")
let client = Client(configuration: clientConf)
client.observers = [Logger()]


// just a Hack to see request curl

let request = NSMutableURLRequest(URL: client.faunaRoot)
request.HTTPMethod = "GET"
let string = request.cURLRepresentation(client.session)

//


let exp = Create(Ref.databases,  ["name": "blog_db"])

var json =  exp.toJSON()

let str = stringFormat(json!)





client.query(exp){ result in
    switch result {
    case .Success(let value):
        break
    case .Failure(let error):
        break
    }
}


client.query(Create(Ref.databases, ["name": "blog_db"])){ result in
    switch result {
    case .Success(let value):
        break
    case .Failure(let error):
        break
    }
}

//let doSentence = Do(Create("databases", obj),
//                    Create("databases", Obj(("name", "blog_db_2"))))



// "Basic " + "\("QWxhZGRpbjpvcGVuIHNlc2FtŽQ=="):".dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions([])
//
//"Basic " + "\("QWxhZGRpbjpvcGVuIHNlc2FtŽQ=="):".dataUsingEncoding(NSASCIIStringEncoding)!.base64EncodedStringWithOptions([])


//let clientConfiguration = ClientConfiguration(
//var client = Client(configuration: ClientConfiguration

var fun =  { (a: Int, b: String) in
                return 4.5 }
let mirror = Mirror.init(reflecting: fun)

mirror.description

mirror.displayStyle

mirror.subjectType

mirror.superclassMirror()



var result = [String]()

for prop in mirror.children
{
    prop
    if let name = prop.label
    {
        result.append(name)
    }
    else {
        result.append("Nothing to show")
    }
}

result

//
//mirror.description
//
//mirror.displayStyle
//
//mirror.subjectType
//
//mirror.children
//
//mirror.superclassMirror()
//
//mirror.displayStyle
//
//
//mirror.children.count
