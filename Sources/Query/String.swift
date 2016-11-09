import Foundation

public struct Concat: Fn {

    var call: Fn.Call

    /**
     `Concat` joins a list of strings into a single string value.

     [Reference](https://faunadb.com/documentation/queries#string_functions)

     - parameter strs:      Expresion that should evaluate to a list of strings.
     - parameter separator: A string separating each element in the result. Optional. Default value: Empty String.

     - returns: A Concat expression.
     */
    public init(_ strings: Expr..., separator: Expr? = nil) {
        self.call = fn("concat" => varargs(strings), "separator" => separator)
    }
}

public struct Casefold: Fn {

    var call: Fn.Call

    /**
     `Casefold` normalizes strings according to the Unicode Standard section 5.18 “Case Mappings”.

     To compare two strings for case-insensitive matching, transform each string and use a binary comparison, such as  equals.

     [Reference](https://faunadb.com/documentation/queries#string_functions)

     - parameter str: Expression that exaluates to a string value.

     - returns: A Casefold expression.
     */
    public init(_ str: Expr) {
        self.call = fn("casefold" => str)
    }

}
