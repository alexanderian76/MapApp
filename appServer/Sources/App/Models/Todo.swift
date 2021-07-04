import Fluent
import Vapor


final class Todo: Model, Content {
    static let schema = "todos"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var name: String
    
    @Field(key: "parties")
    var parties: Array<Party>
    
    @Field(key: "partyIds")
    var partyIds: [String]
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "imageId")
    var imageId: String

    init() {
        //self.id = id
        self.name = ""
        self.parties = []
        self.partyIds = []
        self.password = ""
        self.imageId = ""
    }

    init(id: UUID? = nil, title: String, parties: Array<Party>) {
        self.id = id
        self.name = title
        self.parties = parties
        self.partyIds = []
        self.password = ""
        self.imageId = ""
    }
}
