import Fluent

class CreateChat: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("chats")
            .id()
            .field("partyId", .string, .required)
            .field("messages", .array(of: .custom(Dictionary<String,String>())))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("chats").delete()
    }
}
