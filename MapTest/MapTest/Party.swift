//
//  User.swift
//  MapTest
//
//  Created by Alexander Malygin on 27.01.2021.
//

import UIKit
import MapKit

class Party: NSObject, MKAnnotation, Codable{
    var id:String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    var name:String
    var party: String?
    var title: String?{
        return name
    }
    var creator: String
    var participants:Array<String>
    var date:String
    var type:String
    var tittleImage:String
    var images:Array<String>
    
    init(id:String,name:String, party:String,coordinate:CLLocationCoordinate2D, creator:String, participants:Array<String>, date: String, type: String, tittleImage: String, images: Array<String>){
        self.id = id
        self.name = name
        self.subtitle = party
        self.coordinate = coordinate
        self.participants = participants
        if(!self.participants.contains(creator) && creator != ""){
        self.participants.append(creator)
        }
        self.creator = creator
        self.date = date
        self.type = type
        self.tittleImage = tittleImage
        self.images = images
    }
    
    init(name:String, party:String,coordinate:CLLocationCoordinate2D, creator:String, participants:Array<String>, date: String, type: String, tittleImage: String, images: Array<String>){
        self.name = name
        self.subtitle = party
        self.coordinate = coordinate
        self.participants = participants
        if(!self.participants.contains(creator) && creator != ""){
        self.participants.append(creator)
        }
        self.creator = creator
        self.date = date
        self.type = type
        self.tittleImage = tittleImage
        self.images = images
    }
}
extension CLLocationCoordinate2D: Codable{
    public func encode(to encoder: Encoder) throws {
             var container = encoder.unkeyedContainer()
             try container.encode(longitude)
             try container.encode(latitude)
         }
          
         public init(from decoder: Decoder) throws {
             var container = try decoder.unkeyedContainer()
             let longitude = try container.decode(CLLocationDegrees.self)
             let latitude = try container.decode(CLLocationDegrees.self)
             self.init(latitude: latitude, longitude: longitude)
         }
}
