//
//  Chat.swift
//  MapTest
//
//  Created by Alexander Malygin on 13.02.2021.
//

import Foundation
import UIKit

var chats:Array<Chat> = []

class Chat: NSObject, Codable {
    var id:String?
    var partyId:String
    var messages:Array<Dictionary<String,String>>
    
    
    
    
    
    
    init(id:String?, messages:Array<Dictionary<String,String>>, partyId: String){
        self.id = id
        self.messages = messages
        self.partyId = partyId

    }
}

