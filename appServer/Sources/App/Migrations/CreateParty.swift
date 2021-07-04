import Fluent
import MapKit

class CreateParty: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("parties")
            .id()
            .field("title", .string, .required)
            .field("subtitle", .string)
            .field("name", .string)
            .field("party", .string)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("creator", .string, .required)
            .field("participants", .array(of: .string))
            .field("date", .string, .required)
            .field("type", .string)
            .field("tittleImage", .string)
            .field("images", .array(of: .string))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("parties").delete()
    }
}
