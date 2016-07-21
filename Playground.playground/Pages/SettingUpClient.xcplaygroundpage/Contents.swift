//: [Previous](@previous)

/*:
# Setting up fauna client
*/

import Foundation
import FaunaDB


/*:
 **First step to perform fauna queries is to create a fauna client. Fauna client provides a clean interface to perform queries and get result from our fauna db. These request are made asyncronous and we get fauna values back from server through a callback method.**
 */


/*:
 Let's create our client by using Client initialiser.
 */
let ourClientSecret = "our_secret"
let client = Client(secret: ourClientSecret, observers: [Logger()])

/*:
Now we can perform queries using our fauna client.
 */

client.query(Create(ref: Ref("databases"),  params: ["name": "blog_db"])){ result in
    switch result {
    case .Success(let value):
        break
    case .Failure(let error):
        break
    }
}


/*:
 Client initialiser has another parameters that we can set up such as `faunaRoot`, `timeoutInterval` and `observers`. "https://rest.faunadb.com", 60 are the default value of `faunaRoot` and `timeoutInterval` respectively. `observers` can be used to keep waching client networking status, you can add as many observers as you want. Basically Fauna client notify observers before and after a query is performed.
 */

/*:
 ### Logger
 
 Logger is a fauna client observer, which means it conforms to `ClientObserverType`. Basically it aims to be a networking logger and helps us to develop using fauna swift driver. It's up to you use it or create any other observer.
 
 These is an example of what Logger displays in the Xcode console...
 
 ````
 $ curl -i \
	-X POST \
	-H "Content-Type: application/json; charset=utf-8" \
	-H "X-FaunaDB-Formatted-JSON: 1" \
	-H "Authorization: Basic <hidden>" \
	-d "{\"create\":{\"@ref\":\"databases\"},\"params\":{\"object\":{\"name\":\"app_db_3653666273\"}}}" \
	"https://rest.faunadb.com"
 
 RESPONSE STATUS: 201
 
 RESPONSE DATA:
 
 {
     resource = {
        class = {
            "@ref" = databases;
        };
        name = "app_db_3653666273";
        ref = {
            "@ref" = "databases/app_db_3653666273";
        };
        ts = 1468333736839000;
     };
 }
 
 ````

 */


//: [Next](@next)
