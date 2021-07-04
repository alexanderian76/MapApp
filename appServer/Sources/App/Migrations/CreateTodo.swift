import Fluent

class CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos")
            .id()
            .field("title", .string, .required)
            .field("parties", .array(of: .custom(Party())))
            .field("partyIds", .array(of: .string))
            .field("password", .string, .required)
            .field("imageId", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}
