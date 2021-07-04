import Fluent
import Vapor

struct PartyController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("parties")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":partyID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Party]> {
        return Party.query(on: req.db).all()
    }

    func getParty(req: Request, id: UUID) throws -> EventLoopFuture<Party?> {
      //  let ids = try req.content.decode([UUID.self])
        return Party.find(id, on: req.db)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Party> {
        let todo = try req.content.decode(Party.self)
        return todo.save(on: req.db).map { todo }
    }

    func update(req: Request) throws -> EventLoopFuture<Party>{
   /*     let todo = try req.content.decode(Party.self)
        var t:Party?
        let tmp = Party.find(req.parameters.get("id"), on: req.db).map{ (todo:Party?) -> (Party?) in
            t = todo
            return t
        }
        if(t == nil){
        
        return todo.save(on: req.db).map { todo }
        }
            else {
                return todo.update(on: req.db).map { todo }
            }*/
        let todo = try req.content.decode(Party.self)
        
        return Party.find(req.parameters.get("id")!, on: req.db).map({ (party:Party?) -> Party in
            print("PARTY")
            print(todo)
            print(party?.participants)
            party?.participants = todo.participants
            party?.images = todo.images
            party?.tittleImage = todo.tittleImage
            party?.update(on: req.db).map{party?.participants = todo.participants}
            return  party ?? Party()
        })
           // .unwrap(or: Abort(.notFound))
        //.flatMap{  $0.update(on: req.db).map{todo} }
        //    .transform(to: .ok)
      //  let todo = try req.content.decode(Party.self)
     //   return todo.update(on: req.db).map { todo }
    }

    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Party.find(req.parameters.get("id")!, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
