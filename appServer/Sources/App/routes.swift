import Fluent
import Vapor


var room = Room()

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        
        let hello = try req.query.decode(Todo.self)
        return "Hello, \(hello.name ?? "Anonymous")"
    }
    
    
    
    app.get("get",":id") { req -> EventLoopFuture<Todo> in
        let c = TodoController()

        print(req.content)
        print("PARAMS")
        print(req.parameters)
        let queue = DispatchQueue.global(qos: .userInitiated)
        let t = try c.index(req: req)
       // let tmp = try? req.content.decode(Todo.self)
         let id = req.parameters.get("id", as: String.self)

       // return tmp ?? Todo(title: "test")

            return t
            .map { (rawList: [Todo] ) -> Todo in
                    var result = Todo()
            
                    for rawItem in rawList {
                        if(rawItem.name == id) {result = rawItem}
                        
                    }
             /* for item in result.partyIds{
                    var tmp : Bool = false
                        
                    try? Party.find(UUID(item)!, on: req.db).map({ (todo:Party?) -> Bool in
                        if todo == nil{
                            tmp = true
                            print("TMPPP")
                            print(tmp)
                            if(tmp){
                                print(item)
                                result.partyIds.remove(at: result.partyIds.firstIndex(of: item)!)
                                print(result.partyIds)
                            }
                            
                             return true
                        }
                        else{
                            tmp = false
                            return false
                        }
                     
                     })
               }

                print(result.partyIds)*/
                    return result
                
                }
        }
    
    app.get("getAll",":ids"){ req -> EventLoopFuture<[Todo]> in
        let c = TodoController()
        let t = try c.index(req: req)
        
        let idstr = req.parameters.get("ids")!
        print("IDS")
        print(idstr)
        var ids = idstr.components(separatedBy: ",")
        ids.removeLast()
        print(ids)
        return t
            .map { (users:[Todo]) -> ([Todo]) in
                var arr:Array<Todo> = []
                for item in users{
                    if(ids.contains(item.name)){
                        arr.append(item)
                    }
                }
                return arr
            }
    }
    
    app.post("add"){req -> EventLoopFuture<Todo> in
        let c = TodoController()
        let t = try c.create(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.post("update",":id"){req -> EventLoopFuture<Todo> in
        let c = TodoController()
        let t = try c.update(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.post("post"){req -> EventLoopFuture<Todo> in
        let c = TodoController()
        let t = try c.create(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.get("getParty") { req -> EventLoopFuture<[Party]> in
        let c = PartyController()
        let t = try c.index(req: req)
       // let tmp = try? req.content.decode(Todo.self)
        
       // return tmp ?? Todo(title: "test")
        return t
            .map { (rawList: [Party]) -> [Party] in
                    var result = Array<Party>()
                    for rawItem in rawList {
                        result.append(rawItem)
                    }
            
                    return result
                }
    }
    
    
    app.post("addParty"){ req -> EventLoopFuture<Party> in
        let c = PartyController()
        let t = try c.create(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.post("deleteParty",":id"){ req -> EventLoopFuture<HTTPStatus> in
        print("DELETE REQUEST")
        print(req.parameters.get("id")!)
        let c = PartyController()
        let t = try c.delete(req: req)

        return t
    }
    
    app.post("updateParty",":id"){ req -> EventLoopFuture<Party> in
        print("UPDATE REQUEST")
        print(req.parameters.get("id"))
        let c = PartyController()
        let t = try c.update(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.get("getChat", ":id", ":index"){ req -> EventLoopFuture<Chat> in
        print("GET CHAT")
        let c = ChatController()
        let t = try c.getChat(req: req, id: UUID(uuidString: req.parameters.get("id")!)!)
        
        return t
            .map { (chat:Chat?) -> (Chat) in
                
                let index = Int(req.parameters.get("index")!)!
                let count = chat?.messages.count
               print(count!)
                var tmpChat:Chat = Chat()
                if count! > 0 && index < count!{
                for i in index...count!-1{
                    print("Это i")
                    print(i)
                    tmpChat.messages.append((chat?.messages[i])!)
                }
                }
                return Chat(partyId: chat!.partyId, messages: tmpChat.messages)
            }
        
    }
    
    
    app.get("loadChats",":ids"){ req -> EventLoopFuture<[Chat]> in
        let c = ChatController()
        let t = try c.index(req: req)
        
        let idstr = req.parameters.get("ids")!
        print("IDS")
        print(idstr)
        var ids = idstr.components(separatedBy: ",")
        ids.removeLast()
        print(ids)
        return t
            .map { (chats:[Chat]) -> ([Chat]) in
                var arr:Array<Chat> = []
                for item in chats{
                    if(ids.contains(item.partyId)){
                        arr.append(item)
                    }
                }
                return arr
            }
    }
    
    app.post("createChat"){ req -> EventLoopFuture<Chat> in
        let c = ChatController()
        let t = try c.create(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.post("updateChat",":id"){ req -> EventLoopFuture<Chat> in
        print("UPDATE REQUEST")
        print(req.parameters.get("id"))
        let c = ChatController()
        let t = try c.update(req: req)
        print(req)
       // let tmp = try? req.content.decode(Todo.self)
        //return tmp ?? Todo(title: "testadd")
        return t
    }
    
    app.post("deleteChat",":id"){ req -> EventLoopFuture<HTTPStatus> in
        print("DELETE REQUEST")
        print(req.parameters.get("id")!)
        let c = ChatController()
        let t = try c.delete(req: req)

        return t
    }
    
    
    app.webSocket("chatSocket",":id") { (req, ws) in
        ws.onText { (ws, text) in
            guard
                let data = text.data(using: .utf8),
            let user = try? JSONDecoder().decode(User.self, from: data)
            else{
                print("Cant decode user")
                return
            }
            print(user.username)
            room.connection[user.username] = ws
            room.send(username: user.username, message: user.message, chatId: user.chatId, time: user.time)
        }
        
    }
    
    app.post("upload") { req -> EventLoopFuture<String> in
          let key = try req.query.get(String.self, at: "key")
        print("KEY")
        print(key)
          let path = req.application.directory.publicDirectory + key
        print(path)
          return req.body.collect()
              .unwrap(or: Abort(.noContent))
            .flatMap { req.fileio.writeFile($0, at: path) }
            .map { key }
      }
    // /Users/alexandermalygin/Library/Developer/Xcode/DerivedData/appServer-fumolmjwgncxpkgpqrrpnktshpbc/Build/Products/Debug/Public/9654D189-42C9-408C-BB80-601F78711E0B.png
    app.get("download",":id") { req -> EventLoopFuture<Response> in
        let dir = req.application.directory.publicDirectory
        let dirWithImage = dir + (req.parameters.get("id")! as! String)
        print(dirWithImage)
        print("------------")
        
        return req.eventLoop.makeSucceededFuture(
            req.fileio.streamFile(at: dirWithImage)
          )
       
    }
    
    try app.register(collection: TodoController())
}


struct User: Codable{
    let username: String
    let message: String
    let chatId: String
    let time: String
}


class Room {
    var connection =  [String: WebSocket]()
    
    func send(username:String, message:String, chatId:String, time: String) {
            for (user,websocket) in connection {
            print("KEY")
            print(user)
           //     guard user != username else {continue}
            websocket.send(
                """
                {"chatId": "\(chatId)", "username": "\(username)", "message": "\(message)", "time": "\(time)"}
                """
            )
        }
        
    }
}
