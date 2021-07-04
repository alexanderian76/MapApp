import Fluent
import Vapor


final class Chat: Model, Content {
    static let schema = "chats"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "partyId")
    var partyId: String
    
    
    @Field(key: "messages")
    var messages: Array<Dictionary<String,String>>
    

    init() {
        //self.id = id
        self.partyId = ""
        self.messages = []
    }

    init(id: UUID? = nil, partyId: String, messages: Array<Dictionary<String,String>>) {
        self.partyId = partyId
        self.messages = messages
    }
}
