import FaunaDB

struct Post {
    let ref: RefV?
    let title: String
    let text: String?

    init(ref: RefV? = nil, title: String, text: String? = nil) {
        self.ref = ref
        self.title = title
        self.text = text
    }
}

extension Post: Decodable {
    init?(value: Value) throws {
        try self.init(
            ref: value.get("ref"),
            title: value.get("data", "title") ?? "<No title>",
            text: value.get("data", "text")
        )
    }
}

extension Post: Encodable {
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
    struct Page {
        let refsAndTitles: [RefAndTitle]
        let nextPage: Value?
    }

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

extension Post.Page: Decodable {
    init?(value: Value) throws {
        try self.init(
            refsAndTitles: value.get("data"),
            nextPage: value.get("after")
        )
    }
}

extension Post.RefAndTitle: Decodable {
    init?(value: Value) throws {
        try self.init(
            ref: value.get(0)!,
            title: value.get(1)!
        )
    }
}
