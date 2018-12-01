import FaunaDB

struct Post {

    // Refs are like IDs in other databases
    let ref: RefV?
    let title: String
    let text: String?

    init(ref: RefV? = nil, title: String, text: String? = nil) {
        self.ref = ref
        self.title = title
        self.text = text
    }
}

// Tell the driver how to decode a Post from a value stored at FaunaDB
extension Post: FaunaDB.Decodable {
    init?(value: Value) throws {
        try self.init(
            // `get` receives the path for the value you're looking for.
            // Don't worry about the type, it will try to convert the returned
            // value to the desired type by inference.
            ref: value.get("ref"),
            title: value.get("data", "title") ?? "<No title>",
            text: value.get("data", "text")
        )
    }
}

// Tell the driver how we want to store a Post at FaunaDB
extension Post: FaunaDB.Encodable {
    func encode() -> Expr {
        return Obj(
            "title" => title,
            "text" => text
        )
    }
}

extension Post {
    static func save(_ post: Post) -> QueryResult<Post> {
        if let ref = post.ref {
            return perform(
                Update(
                    ref: ref,
                    // The driver will use the Encodable protocol to
                    // convert the post instance to a valid FaunaDB value
                    to: Obj("data" => post)
                )
            )
        }

        return perform(
            Create(
                at: Class("posts"),
                Obj("data" => post)
            )
        )
    }

    static func load(byRef ref: RefV) -> QueryResult<Post> {
        return perform(Get(ref))
    }

    private static func perform(_ query: Expr) -> QueryResult<Post> {
        return faunaClient.query(query).map { dbEntry in
            // By calling get with no path, we're telling the driver that
            // the root value should be returned. Since we are expecting a Post,
            // the driver will use the Decodable protocol to convert this value
            // into a Post instance.
            try dbEntry.get()!
        }
    }
}

extension Post {
    static func delete(at ref: RefV) -> QueryResult<Void> {
        return faunaClient.query(
            Delete(
                ref: ref
            )
        ).map { _ in }
    }
}

extension Post {
    // Represents each page for the index all_posts_refs_and_titles
    struct Page {
        let refsAndTitles: [RefAndTitle]
        let nextPage: Value?
    }

    // Represents a tuple of (RefV, String)
    struct RefAndTitle {
        let ref: RefV
        let title: String
    }

    var refAndTitle: RefAndTitle? {
        guard let ref = self.ref else {
            return nil
        }

        return RefAndTitle(ref: ref, title: title)
    }

    static func loadRefsAndTitles(cursor: Value? = nil) -> QueryResult<Page> {
        return faunaClient.query(
            Paginate(
                Match(index: Index("all_posts_refs_and_titles")),
                after: cursor,
                size: 15
            )
        )
        .map { indexEntries in
            try indexEntries.get()!
        }
    }
}

extension Post.Page: FaunaDB.Decodable {
    init?(value: Value) throws {
        try self.init(
            // `get` also works woth arrays and objects. In this case,
            // it knows the desired type is [Post.RefAndTitle].
            refsAndTitles: value.get("data"),
            nextPage: value.get("after")
        )
    }
}

extension Post.RefAndTitle: FaunaDB.Decodable {
    init?(value: Value) throws {
        try self.init(
            // You can also use numbers when the value you want is
            // inside an array
            ref: value.get(0)!,
            title: value.get(1)!
        )
    }
}
