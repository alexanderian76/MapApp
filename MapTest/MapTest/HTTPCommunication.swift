import UIKit
import MapKit

// Наследуем от NSObject, чтобы подчиняться (conform) NSObjectProtocol,
// потому что URLSessionDownloadDelegate наследует от этого протокола,
// а раз мы ему подчиняемся, то должны и родительскому протоколу.
class HTTPCommunication: NSObject {
    // Свойство completionHandler в классе - это замыкание, которое будет
    // содержать код обработки полученных с сайта данных и вывода их
    // в интерфейсе нашего приложения.
    var completionHandler: ((Data) -> Void)!
    var webSocketTask: URLSessionWebSocketTask!
    
    // retrieveURL(_: completionHandler:) осуществляет загрузку данных
    // с url во временное хранилище
    // С замыканием мы будем работать вне этой функции,
    // поэтому мы обозначаем ее @escaping.
    func retrieveURL(_ url: URL, completionHandler: @escaping ((Data) -> Void)) {
        self.completionHandler = completionHandler
        let request: URLRequest = URLRequest(url: url)
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask = session.downloadTask(with: request)
        // Так как задача всегда создается в остановленном состоянии,
        // мы запускаем ее.
       // let task = URLSession.shared.dataTask(with: url){(data, response, error) in
      //  guard let data = data else {
      //      return
      //  }
      //  }
        task.resume()
    }
    
    
    
    func postParty(tmpParty:Party?){
        let url = URL(string: "http://127.0.0.1:8080/addParty")!
        
        let parameters:Dictionary<String,Any> = ["name" : tmpParty?.name, "title" : tmpParty?.title, "party" : tmpParty?.party, "subtitle" : tmpParty?.subtitle, "latitude" : tmpParty?.coordinate.latitude, "longitude" : tmpParty?.coordinate.longitude, "creator": tmpParty?.creator, "participants": tmpParty?.participants, "date" : tmpParty?.date, "type" : tmpParty?.type, "tittleImage" : tmpParty?.tittleImage, "images" : tmpParty?.images]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){ [self]
            (data, response, error) in
            if let response = response{
                print("RESPONSE")
             //   print(response)
            }
           // print(request)
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let id = try json as! [String:Any]
                user.partyIds.append(id["id"] as! String)
                self.createChat(chat: Chat(id: nil, messages: [], partyId: id["id"] as! String))
                self.updateUser()
                print("АЙДИ ДОБАВЛЕН")
                print(json)
            }
            catch{
               // print(error)
            }
        }.resume()
    }
    
    func getUser(_ id: String?){
        let http: HTTPCommunication = HTTPCommunication()
        let url:URL
        if(id != nil){
            url = URL(string: "http://127.0.0.1:8080/get/" + id!)!
        }
        else{
            url = URL(string: "http://127.0.0.1:8080/get/.")!
        }
        print(url)
        http.retrieveURL(url) {
            [weak self] (data) -> Void in
            
            
                guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
                
                print("JSON: ", jsonUser)
                print(jsonUser)
            
            
            
            do{
                
            
            let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonObject = jsonObjectAny as! [String:Any]
                
                
            user.name = jsonObject["name"] as! String
            user.partyIds = jsonObject["partyIds"] as! Array<String>
            UserDefault.userName = jsonObject["name"] as! String
            UserDefault.userPassword = jsonObject["password"] as! String
                
            }
            catch{
                print("Ошибка")
            }
           // self?.tableView.reloadData()
            
        }
    }
    
    func getUser(_ id: String?, complition: @escaping ((Data) -> Void)){
        let http: HTTPCommunication = HTTPCommunication()
        let url:URL
        if(id != nil){
            url = URL(string: "http://127.0.0.1:8080/get/" + id!)!
        }
        else{
            url = URL(string: "http://127.0.0.1:8080/get/.")!
        }
        print(url)
        http.retrieveURL(url,completionHandler: complition)
        }
    
    func getUsers(ids:Array<String>, complition: @escaping ((Data) -> Void)){
        let http: HTTPCommunication = HTTPCommunication()
        print("IDS")
        print(ids)
        var str = ""
        for item in ids{
            str = str + item + ","
        }
        let url: URL = URL(string: "http://127.0.0.1:8080/getAll/" + str)!
        http.retrieveURL(url, completionHandler: complition)
    }
    
    
    func updateUser(){
        let url = URL(string: "http://127.0.0.1:8080/update/\(user.id!)")!
        
        let parameters:Dictionary<String,Any> = ["id":user.id!,"name" : UserDefault.userName!,"parties" : user.parties, "partyIds" : user.partyIds, "password" : UserDefault.userPassword!, "imageId" : user.imageId]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
       
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
       // request.addValue("multipart/form-data; boundary=Boundary-\(UUID().uuidString)", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){
            (data, response, error) in
            if let response = response{
                print(response)
            }
            print(request)
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            }
            catch{
                print(error)
            }
        }.resume()
    }
    
    //D6FE5297-2D55-49A0-A1F7-6DF3BAF52717
    func postUser(){
        let url = URL(string: "http://127.0.0.1:8080/post")!
        
        let parameters:Dictionary<String,Any> = ["name" : UserDefault.userName!,"parties" : user.parties, "partyIds" : user.partyIds, "password" : UserDefault.userPassword!, "imageId" : user.imageId]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
       
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
       // request.addValue("multipart/form-data; boundary=Boundary-\(UUID().uuidString)", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){
            (data, response, error) in
            if let response = response{
                print(response)
            }
            print(request)
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let id = try json as! [String:Any]
                user.id = id["id"] as! String
                print(json)
            }
            catch{
                print(error)
            }
        }.resume()
    }
    
    func retrieveData(_ ids: Array<String>?,tableView:UITableView?) {
        let http: HTTPCommunication = HTTPCommunication()
        // Посколько мы жестко кодируем url в код, то и сразу force unwrap его
        // Если url невалидный, то наше приложение уже бесполезно
        let url: URL = URL(string: "http://127.0.0.1:8080/getParty")!

        http.retrieveURL(url) {
            // Чтобы избежать захвата self в замыкании, делаем weak self
            [weak self] (data) -> Void in
            
            // Получаем и распечатываем строковое представление json
            // данных, чтобы знать, в какой формат их переводить. Если
            // не можем получить нормальный json из загруженных данных,
            // то дальше уже не идем.
            guard let json = String(data: data, encoding: String.Encoding.utf8) else { return }
            // Пример распечатки: JSON:  { "type": "success", "value":
            // { "id": 391, "joke": "TNT was originally developed by Chuck
            // Norris to cure indigestion.", "categories": [] } }
            print("JSON: ", json)
                
            do {
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Проверяем, что мы можем переводить данные из Any
                // в нужный нам формат, иначе дальше не идем.
                print(jsonObjectAny as? [String:Any])
                
                var id:Any
                var name:String
                var title:String
                var long:Double?
                var lat:Double?
                let jsonObject = jsonObjectAny as! [[String:Any]]
                parties = []
                if(ids == nil){
                    
                for item in jsonObject{
                    
                    parties.append(Party(id: item["id"] as! String, name: item["name"] as! String, party: item["party"] as! String, coordinate: CLLocationCoordinate2D(latitude: item["latitude"] as! Double, longitude: item["longitude"] as! Double), creator: item["creator"] as! String, participants: item["participants"] as! Array<String>, date: item["date"] as! String, type: item["type"] as! String, tittleImage: item["tittleImage"] as! String, images: item["images"] as! Array<String>))
                }
                }
                else {
                    for item in jsonObject{
                        if(ids!.contains(item["id"] as! String)){
                      //      var participants = item["participants"] as! Array<String>
                       //     if(!participants.contains(user.name)){
                      //          participants.append(user.name)
                      //      }
                            let dateFormatter = DateFormatter()
                           // dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                            let date = dateFormatter.date(from:item["date"] as! String)!
                            if date < Date(){
                                self?.deleteChat(id: chats.first(where: { (chat:Chat) -> Bool in
                                    chat.partyId == item["id"] as! String
                                })!.id!) { [weak self] (data, response, error) in
                                    if let response = response{
                                        print("RESPONSE DELETE CHAT")
                                        print(response)
                                }
                                }
                                self?.deleteParty(id: item["id"] as! String) { [weak self] (data, response, error) in
                                    if let response = response{
                                        print("RESPONSE")
                                        print(response)
                                    }
                                   // print(request)
                                    guard let data = data else {return}
                                    do{
                                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                                        let id = try json as! [String:Any]
                                        
                                        print("АЙДИ УДАЛЕН")
                                        print(json)
                                       
                                    }
                                    catch{
                                       // print(error)
                                    }
                                }
                            }
                            else{
                            parties.append(Party(id: item["id"] as! String, name: item["name"] as! String, party: item["party"] as! String, coordinate: CLLocationCoordinate2D(latitude: item["latitude"] as! Double, longitude: item["longitude"] as! Double), creator: item["creator"] as! String, participants: item["participants"] as! Array<String>, date: item["date"] as! String, type: item["type"] as! String, tittleImage: item["tittleImage"] as! String, images: item["images"] as! Array<String>))
                        }
                        }
                    }
                }
             //   self?.tableView.reloadData()
                if(user.partyIds.count != parties.count){
                    for id in user.partyIds{
                        
                        if(!parties.contains(where: { (party:Party) -> Bool in
                            return id == party.id
                        })){
                            user.partyIds.remove(at: user.partyIds.firstIndex(of: id)!)
                        }
                    }
                    http.updateUser()
                }
                tableView?.reloadData()
               /* guard
                    let jsonObject = jsonObjectAny as? [String:Any],
                   // let value = jsonObject["value"] as? [String: Any],
                
                    let id = jsonObject["id"],
                    let name = jsonObject["name"] as? String,
                    let title = jsonObject["title"] as? String,
                    let long = jsonObject["longitude"] as? Double?,
                    let lat = jsonObject["latitude"] as? Double?
                
                else {
                        return
                }*/
              //  print(name)
             //   self?.parties
                //self?.currentUser.name = name
               // self?.tableView.reloadData()
                // Когда данные получены и расшифрованы,
                // мы останавливаем наш индикатор и он исчезает.
                //self.activityView.stopAnimating()
               // self.jokeID = id
               // self.jokeLabel.text = joke
            } catch {
                print("Can't serialize data.")
            }
        }
    }
    
    func retrieveParties(_ ids: Array<String>?,tableView:UITableView?,_ complition: @escaping ((Data) -> Void)) {
        let http: HTTPCommunication = HTTPCommunication()
        let url: URL = URL(string: "http://127.0.0.1:8080/getParty")!
        http.retrieveURL(url, completionHandler: complition)
    }
    
    
    func deleteParty(id : String,_ complition: @escaping ((Data?, URLResponse?, Error?) -> Void)){
        let url = URL(string: "http://127.0.0.1:8080/deleteParty/\(id)")!
        let parameters:Dictionary<String,Any> = ["id":id]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: complition).resume()
    }
    
    
    func updateParty(tmpParty: Party){
        let url = URL(string: "http://127.0.0.1:8080/updateParty/\(tmpParty.id!)")!
        let parameters:Dictionary<String,Any> = ["name" : tmpParty.name, "title" : tmpParty.title, "party" : tmpParty.subtitle, "subtitle" : tmpParty.subtitle, "latitude" : tmpParty.coordinate.latitude, "longitude" : tmpParty.coordinate.longitude, "creator": tmpParty.creator, "participants": tmpParty.participants, "date" : tmpParty.date, "type" : tmpParty.type, "tittleImage" : tmpParty.tittleImage, "images" : tmpParty.images]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){
            (data, response, error) in
            if let response = response{
                print("RESPONSE")
                print(response)
            }
           // print(request)
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let id = try json as! [String:Any]
             //   user.partyIds.append(id["id"] as! String)
               // self.postUser()
                print("АЙДИ ДОБАВЛЕН")
                print(json)
            }
            catch{
               // print(error)
            }
        }.resume()
    }
    
    func createChat(chat:Chat){
        let url = URL(string: "http://127.0.0.1:8080/createChat")!
        let parameters:Dictionary<String,Any> = ["partyId" : chat.partyId, "messages" : [] ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){
            (data, response, error) in
            if let response = response{
                print("RESPONSE")
                print(response)
            }
           // print(request)
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let id = try json as! [String:Any]
             //   user.partyIds.append(id["id"] as! String)
               // self.postUser()
                chats.append(Chat(id: id["id"] as! String, messages: [], partyId: chat.partyId))
                print(chats)
                print("АЙДИ ЧАТА ДОБАВЛЕН")
                print(json)
            }
            catch{
               // print(error)
            }
        }.resume()
    }
    
    
    func deleteChat(id : String,_ complition: @escaping ((Data?, URLResponse?, Error?) -> Void)){
        let url = URL(string: "http://127.0.0.1:8080/deleteChat/\(id)")!
        let parameters:Dictionary<String,Any> = ["partyId":id]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: complition).resume()
    }
    
    
    func getChat(_ id: String, index: String, complition: @escaping ((Data) -> Void)){
        let http: HTTPCommunication = HTTPCommunication()
        let url: URL = URL(string: "http://127.0.0.1:8080/getChat/\(id)/\(index)")!
        http.retrieveURL(url, completionHandler: complition)
    }
    
    func updateChat(chat:Chat, index: String, tableView:UITableView?){
        let url = URL(string: "http://127.0.0.1:8080/updateChat/\(chat.id!)")!
        let parameters:Dictionary<String,Any> = ["id": chat.id!, "partyId" : chat.partyId, "messages" : chat.messages ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options:[]) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){
            (data, response, error) in
            if let response = response{
                print("RESPONSE")
                print(response)
            }
           // print(request)
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let id = try json as! [String:Any]
             //   user.partyIds.append(id["id"] as! String)
               // self.postUser()
                self.getChat(chat.id!, index: index) {[weak self] (data) -> Void in
                    
                    guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
                    print("JSON CHAT: ", jsonUser)
                    print(jsonUser)
                  
                do{
                        
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonObject = jsonObjectAny as! [String:Any]
                    
                   
                     chats.first { (chat:Chat) -> Bool in
                        chat.partyId == jsonObject["partyId"] as! String
                    }?.messages.append(contentsOf: jsonObject["messages"] as! Array<Dictionary<String,String>>)
                    let tmp = chat.messages.count
                    chat.messages.append(contentsOf: jsonObject["messages"] as! Array<Dictionary<String,String>>)
                    print(chat.messages.count)
                    print(Int(index)!)
                    tableView?.reloadData()
                    tableView?.scrollToRow(at: IndexPath(item: Int(index)! + chat.messages.count-1 - tmp, section: 0), at: .bottom, animated: true)
                    //tableView?.beginUpdates()
                }
                catch{
                    print("Ошибка")
                }
                //self?.tableView.reloadData()
            }
                print("АЙДИ ДОБАВЛЕН")
                print(json)
                
            }
            catch{
               // print(error)
            }
           // tableView?.scrollToRow(at: IndexPath(item: (tableView?.numberOfRows(inSection: 0))!, section: 0), at: .bottom, animated: true)
            
        }.resume()
    }
    
    
    func loadChats(ids:Array<String>, complition: @escaping ((Data) -> Void)){
        let http: HTTPCommunication = HTTPCommunication()
        print("IDS")
        print(ids)
        var str = ""
        for item in ids{
            str = str + item + ","
        }
        let url: URL = URL(string: "http://127.0.0.1:8080/loadChats/" + str)!
        http.retrieveURL(url, completionHandler: complition)
    }
    
    
    func setupWebSocket(chat:Chat,tableView:UITableView){
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: URL(string : "ws://127.0.0.1:8080/chatSocket/\(chat.id!)")!)
        webSocketTask.resume()
        recieveMessage(tableView: tableView)
      
    }
    
    func closeSocket(){
        webSocketTask.cancel()
    }
    
    func recieveMessage(tableView:UITableView){
        webSocketTask.receive {[weak self] result in
            switch result{
            case .failure(let error): print("Mistake in recieving")
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data \(data)")
                case .string(let message):
                    do {
                    let data = message.data(using: .utf8)
                        
                    let tmp = try? JSONDecoder().decode(MessageData.self, from: data!)
                        let tmpChat = chats.first(where: { (chat) -> Bool in
                            chat.id == tmp?.chatId
                        })
                        if tmpChat != nil {
                        let c = Chat(id: tmpChat!.id!, messages: [["chat": tmpChat!.id!, "message": tmp?.message as! String, "sender": tmp?.username as! String]], partyId: tmpChat!.partyId)
                            if unreadMessages[tmpChat!.id!] == nil {
                                unreadMessages[tmpChat!.id!] = 0
                            }
                            unreadMessages[tmpChat!.id!]! += 1
                            self?.updateChat(chat: c, index: String(tmpChat!.messages.count), tableView: tableView)
                        }
                    }
                default: print("do nothing")
                }
                self?.recieveMessage(tableView: tableView)
            }
            
        }
        
        
    }
    
    
    func sendMessage(chat:Chat,message:String){
        var msg = ""
        for item in message{
            if item == """
\n
"""
                || item ==
                """
\\
"""
            {
                msg.append(" ")
            }
            else{
            msg.append(item)
            }
           
        }
        let message = URLSessionWebSocketTask.Message.string(
            """
            {"chatId": "\(chat.id!)", "username": "\(UserDefault.userName!)", "message": "\(msg)", "time": "no date yet"}
            """
        )
        webSocketTask.send(message) { (error) in
            if let error = error { print("Mistake in websocket")}
        }
    }
    
    func uploadFile(fileData:Data, id:String){
    var request = URLRequest(url: URL(string: "http://localhost:8080/upload?key=\(id).jpg")!)
    request.httpMethod = "POST"
    request.httpBody = fileData

    let task = URLSession.shared.uploadTask(with: request) { data, response, error in
        guard error == nil else {
            fatalError(error!.localizedDescription)
        }
        guard let response = response as? HTTPURLResponse else {
            fatalError("Invalid response")
        }
        guard response.statusCode == 200 else {
            fatalError("HTTP status error: \(response.statusCode)")
        }
        guard let data = data, let result = String(data: data, encoding: .utf8) else {
            fatalError("Invalid or missing HTTP data")
        }
        print(result)
       // exit(0)
    }.resume()
    }
    
    func downloadFile(fileId:String, complition: @escaping ((Data) -> Void)){
        let url: URL = URL(string: "http://127.0.0.1:8080/download/\(fileId).jpg")!
        retrieveURL(url, completionHandler: complition)
    }

    
}


struct MessageData : Codable{
    let username: String
    let message: String
    let chatId: String
    let time: String
}

// Мы создаем расширение класса, которое наследует от NSObject
// и подчиняется(conforms) протоколу URLSessionDownloadDelegate,
// чтобы использовать возможности данного протокола для обработки
// загруженных данных.
extension HTTPCommunication: URLSessionDownloadDelegate {

    // Данный метод вызывается после успешной загрузки данных
    // с сайта во временное хранилище для их последующей обработки.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            // Мы получаем данные на основе сохраненных во временное
            // хранилище данных. Поскольку данная операция может вызвать
            // исключение, мы используем try, а саму операцию заключаем
            // в блок do {} catch {}
            let data: Data = try Data(contentsOf: location)
            // Далее мы выполняем completionHandler с полученными данными.
            // А так как загрузка происходила асинхронно в фоновой очереди,
            // то для возможности изменения интерфейса, которой работает в
            // главной очереди, нам нужно выполнить замыкание в главной очереди.
            DispatchQueue.main.async(execute: {
                self.completionHandler(data)
            })
        } catch {
            print("Can't get data from location.")
        }
    }
}

extension URLSession {

    func uploadTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        uploadTask(with: request, from: request.httpBody, completionHandler: completionHandler)
    }
}
