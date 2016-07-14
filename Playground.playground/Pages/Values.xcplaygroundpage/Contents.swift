//: [Previous](@previous)

import Foundation
import FaunaDB


/*:
 These are all fauna values available in swift driver. 
 > Whenever possible swift driver tries to use build-in types as fauna types to improve interoperability between your app code and fauna db storage.
 */

/*:
 ### Literals
 */

/*:
 Booleans
 */
let _ = false
let bool: Bool = true

/*:
 Integers
 */

let _ = 3
let int: Int = 5


/*:
 Decimals
 */

let _ = 3.4
let decimal: Double = 3.4

/*:
 Strings
 */

let _ = "Fauna DB!"
let str: String = "Fauna DB!"

/*:
 Null
 */

let nilValue: Null = nil
let anotherNilValue = Null()


/*:
 ### Arrays
 */

var arrVar = Arr(2, 4, "Hi")

/*:
 Arr conforms to ArrayLiteralConvertible which means we can initialise an Arr using array literal form.
 */

let arr: Arr = [int, decimal, str, bool]
let arr1:Arr = [1, 3, "Hi", true, 3.141562]

/*:
 Arr also conforms to CollectionType standar library protocol so we have a bunch of useful collection methods and properties available to work with Fauna arr. Let's see some examples...
 */

var mutableArr = Arr(1,2,3)

mutableArr.count
mutableArr.append("Fauna DB!")
let firstItem = mutableArr.first

mutableArr[1] = "Fauna"

let containsValue3: Bool = mutableArr.contains { ($0 as? Int) == 3}
var intArr = mutableArr.filter { $0 is Int }



/*:
 Even though `Arr` is not a swift build-in type it share some default definition since it conforms to CollectionType and related protocols. This made super simple to create a build-in type from an Arr.
 */

var array: [Value] = []
array.appendContentsOf(mutableArr)


var anArr = Arr(array)

anArr = anArr + array


/*:
 ### Objects
 */

/*:
 Similar to Arr type, Obj type conforms to DictionaryLiteralConvertible and CollectionType.
 */

let objectValue: Obj = ["@name": "Hen Wen", "age": 110]
var objectValue2: Obj = ["@obj": objectValue]

objectValue2["newKey"] = Date(day: 18, month: 07, year: 1984)

objectValue2.forEach { key, value in
    "\(key): \(value)"
}


/*:
 ### Special Types
 */


/*:
 Ref. Denotes a resource ref. Refs may be extracted from instances, or constructed using the Ref type initialiser.
 */

var ref = Ref("databases")
ref = Ref("classes")
ref = Ref("indexes")
ref = Ref(ref: Ref("classes"), id: "8764")



/*:
 Timestamp, Fauna Timestamp is actually a NSDate build-in type. It denotes a time.
 */
let time: Value = Timestamp(timeIntervalSince1970: 0)
let time2: Value = NSDate()
let time3: Timestamp? = Timestamp(iso8601:"1970-01-01T00:00:00Z")

/*:
 Date, Fauna Date is actually a NSDateComponents build-in type. It represent a specific date.
 */

let dateVale:Date = Date(day: 18, month: 07, year: 1984)
let dateVale2:Date = NSDateComponents(day: 18, month: 07, year: 1984)


//: [Ne