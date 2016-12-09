import FaunaDB

// This database setup would be probably done somewhere else in a real
// application, like in your provision scripts. But here we are setting up a
// simple database just so you don't have to while playing with this example
// app.

fileprivate let dbName = "faunadb-example-ios"
fileprivate let database = Ref("databases/" + dbName)

func setupDatabase(rootKey: String, endpoint: String? = nil) -> QueryResult<FaunaDB.Client> {
    let adminClient = newFaunaClient(
        rootKey: rootKey,
        endpoint: endpoint
    )

    return getOrCreateDatabase(with: adminClient)
}

fileprivate func getOrCreateDatabase(with adminClient: FaunaDB.Client) -> QueryResult<FaunaDB.Client> {
    return adminClient.query(
        Exists(database)
    )
    .flatMap { res in
        guard let exists = try res.get() as Bool?, exists else {
            return createDatabase(with: adminClient)
        }

        return newSessionClient(with: adminClient)
    }
}

fileprivate func createDatabase(with adminClient: FaunaDB.Client) -> QueryResult<FaunaDB.Client> {
    let databaseClient = adminClient.query(
        CreateDatabase(Obj(
            "name" => dbName
        ))
    )
    .flatMap { _ in
        newSessionClient(with: adminClient)
    }

    return databaseClient.flatMap { client in
        client.query(
            CreateClass(Obj(
                "name" => "posts"
            ))
        )
        .flatMap { _ in
            client.query(
                // The index will be a sequence of tuples like (RefV, String)
                CreateIndex(Obj(
                    "name" => "all_posts_refs_and_titles",
                    "source" => Class("posts"),
                    "values" => Arr(
                        Obj("field" => Arr("ref"), "reverse" => true),
                        Obj("field" => Arr("data", "title"))
                    )
                ))
            )
        }
        .map { _ in client }
    }
}

fileprivate func newSessionClient(with client: FaunaDB.Client) -> QueryResult<FaunaDB.Client> {
    return client.query(
        CreateKey(Obj(
            "database" => database,
            "role" => "server"
        ))
    )
    .map { key in
        client.newSessionClient(secret: try key.get("secret") ?? "")
    }
}

fileprivate func newFaunaClient(rootKey: String, endpoint: String?) -> FaunaDB.Client {
    guard let endpoint = URL(string: endpoint ?? "") else {
        return FaunaDB.Client(secret: rootKey)
    }

    return FaunaDB.Client(secret: rootKey, endpoint: endpoint)
}
