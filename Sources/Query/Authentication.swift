import Foundation

public struct Login: Fn {

    var call: Fn.Call

    /**
     `Login` creates a token for the provided ref.

     [Reference](https://faunadb.com/documentation/queries#auth_functions)

     - parameter ref:    A Ref instance or something that evaluates to a `Ref` instance.
     - parameter params: Expression which provides the password.

     - returns: A `Login` expression.
     */
    public init(for ref: Expr, _ params: Expr) {
        self.call = fn("login" => ref, "params" => params)
    }

}

public struct Logout: Fn {

    var call: Fn.Call

    /**
     `Logout` deletes all tokens associated with the current session if its parameter is `true`, or just the token used in this request otherwise.

     - parameter invalidateAll: if true deletes all tokens associated with the current session. If false it deletes just the token used in this request.

     - returns: A `Logout` expression.
     */
    public init(all: Expr) {
        self.call = fn("logout" => all)
    }

}

public struct Identify: Fn {

    var call: Fn.Call

    /**
     `Identify` checks the given password against the ref’s credentials, returning `true` if the credentials are valid, or `false` otherwise.

     - parameter ref:      Identifies an instance.
     - parameter password: Password to check agains `ref` instance.

     - returns: A `Identify` expression.
     */
    public init(ref: Expr, password: Expr) {
        self.call = fn("identify" => ref, "password" => password)
    }

}
