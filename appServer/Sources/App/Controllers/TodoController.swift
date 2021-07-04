import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db).all()
    }

    func update(req: Request) throws -> EventLoopFuture<Todo>{

        let todo = try req.content.decode(Todo.self)
        
        return Todo.find(req.parameters.get("id")!, on: req.db).map({ (user:Todo?) -> Todo in
            print("TODO")
            print(todo)
          //  print(user?.messages)
       //     chat?.messages = todo.messages
            user?.imageId = todo.imageId
            user?.partyIds = todo.partyIds
            user?.update(on: req.db).map{
                user?.imageId = todo.imageId
                user?.partyIds = todo.partyIds
                
                }
            print(user?.partyIds)
           // print(user?.messages)
          //  chat?.update(on: req.db).map{chat?.messages = todo.messages}
            return  user ?? Todo()
        })

    }
    
    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)
        //if(Todo.find(UUID(uuidString: req.parameters.get("id")!), on: req.db) != nil){
   /*     var t:Todo?
        let tmp = Todo.find(req.parameters.get("title"), on: req.db).map{ (todo:Todo?) -> (Todo?) in
            t = todo
            return t
        }
        if(t == nil){
        
        return todo.save(on: req.db).map { todo }
        }
            else {
                return todo.update(on: req.db).map { todo }
            }*/
        return todo.save(on: req.db).map { todo }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
