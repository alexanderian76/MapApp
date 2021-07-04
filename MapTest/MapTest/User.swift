//
//  User.swift
//  MapTest
//
//  Created by Alexander Malygin on 28.01.2021.
//

import UIKit
import MapKit
import Foundation

var user = User(name:UserDefault.userName ?? "Empty")


class User: NSObject, Codable {
    var id:String?
    var name:String
    var parties:Array<Party> = []
    var partyIds:Array<String> = []
    var imageId:String = ""
    var password:String
    
    
    init(name:String){
        self.name = name
        self.parties = []
        self.partyIds = []
        self.password = ""
        self.imageId = ""
    }
    
    init(id:String?, name:String, partyIds:Array<String>, imageId:String){
        self.id = id
        self.name = name
        self.parties = []
        self.partyIds = partyIds
        self.password = ""
        self.imageId = imageId
    }
}

