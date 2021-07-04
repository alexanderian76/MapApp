import Foundation

class Message: NSObject, Codable {
 //   var chatId:String
    var message:String
    var sender:String
    var time:String
    
    
    override init(){
        self.message = ""
        self.sender = ""
        self.time = ""
    }
    
    
    init(message:String, sender:String){
      //  self.chatId = chat
        self.message = message
        self.sender = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.time = formatter.string(from: Date())

    }
}
