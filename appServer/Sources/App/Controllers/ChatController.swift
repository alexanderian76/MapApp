import Fluent
import Vapor

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("chats")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":chatID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Chat]> {
        return Chat.query(on: req.db).all()
    }

    func getChat(req: Request, id: UUID) throws -> EventLoopFuture<Chat?> {
        print("GET CHAT")
        print(id)
        return Chat.find(id, on: req.db)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Chat> {
        let todo = try req.content.decode(Chat.self)
        return todo.save(on: req.db).map { todo }
    }

    func update(req: Request) throws -> EventLoopFuture<Chat>{

        let todo = try req.content.decode(Chat.self)
        
        return Chat.find(req.parameters.get("id")!, on: req.db).map({ (chat:Chat?) -> Chat in
            print("CHAT")
            print(todo)
            print(chat?.messages)
       //     chat?.messages = todo.messages
            for item in todo.messages{
            chat?.messages.append(item)
            }
            chat?.update(on: req.db).map{
                for item in todo.messages{
                chat?.messages.append(item)
                }
                }
            print(chat?.messages)
          //  chat?.update(on: req.db).map{chat?.messages = todo.messages}
            return  chat ?? Chat()
        })

    }

    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Chat.find(req.parameters.get("id")!, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
