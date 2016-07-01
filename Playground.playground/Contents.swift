//
//  Playground.playground
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

//: Playground - noun: a place where people can play

import UIKit
import Foundation
import FaunaDB
import Result

func stringFormat(json: AnyObject) -> String{
    let jsonData = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
    let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
    return jsonString
}

// ref

let refValue = Ref.databases
let anotherRefValue: Ref = "databases"

// Null

let nilValue: Null = nil
let anotherNilValue = Null()


// ArrayValue

var array: Arr = [3, "Hola", 3.34, true, Double(3.34), refValue, anotherRefValue, nilValue, anotherNilValue]
let arrayStr = String(array)

// any array is a ValueConvertible so we can create a Value representation from it
let anyArrayType: [Any] = [3, "Hola", 3.34, true, Double(3.34), refValue, anotherRefValue, nilValue, anotherNilValue]

// we can compare it
anyArrayType.value.isEquals(array)

// another Collection type protocol extension addition.
array.append("new scalar value")

/// We can apply functional methods to Arr and Obj types since they conforms to CollectionType
var nullArray = array.filter { $0 is Null }

/// replace an arr item using subscript
nullArray[1] = "Hi"

// another function
nullArray.removeLast()

let arrayOfArray: Arr = [array, array]

// creates an Obj from dictionary literal
let objectValue: Obj = ["@name": "Hen Wen", "age": 110]
let objectValue2: Obj = ["@obj": objectValue]


/// Values, we can use swift values
let intValue: Value = 1
let doubleValue: Value = 2.4
let stringValue: Value = "string value"
/// Timestamp is just a swift NSDate typealias
let timeValue: Value = Timestamp()
let timeValue2: Value = NSDate()
/// Date is just a swift NSDateComponents typealias
let dateVale:Value = Date(day: 18, month: 07, year: 1984)
let dateVale2:Value = NSDateComponents(day: 18, month: 07, year: 1984)








let clientConf = ClientConfiguration(secret: "")
let client = Client(configuration: clientConf)
client.observers = [Logger()]


// just a Hack to see request curl

let request = NSMutableURLRequest(URL: client.faunaRoot)
request.HTTPMethod = "GET"
//let string = request.cURLRepresentation(client.session)



let exp = Create(ref: Ref.databases,  params: ["name": "blog_db"])

var json =  exp.toJSON()

let str = stringFormat(json)





client.query(exp){ result in
    switch result {
    case .Success(let value):
        break
    case .Failure(let error):
        break
    }
}


client.query(Create(ref: Ref.databases, params: ["name": "blog_db"])){ result in
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

for prop in mirror.children{
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
