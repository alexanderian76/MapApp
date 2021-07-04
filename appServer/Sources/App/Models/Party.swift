import Fluent
import Vapor
import MapKit

final class Party: Model, Content {
    static let schema = "parties"
    
    @ID(key: .id)
    var id: UUID?

   // @Field(key: "partyId")
   // var partyId: String = ""
    
    @Field(key: "title")
    var name: String
    
    @Field(key: "subtitle")
    var subtitle: String

    init() { }

    //@Field(key: "coord")
    //var coordinate: CLLocationCoordinate2D
    
    @Field(key: "latitude")
    var latitude: Double
    
    @Field(key: "longitude")
    var longitude: Double
    
    @Field(key: "party")
    var party: String
    
    @Field(key: "name")
    var title: String
    
    @Field(key: "creator")
    var creator: String
    
    @Field(key: "participants")
    var participants: Array<String>
    
    @Field(key: "date")
    var date: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "tittleImage")
    var tittleImage: String
    
    @Field(key: "images")
    var images: Array<String>
    
    init(id: UUID? = nil, name:String, party:String,lat : Double, long: Double, creator: String, participants: Array<String>, date: String, type: String){
        self.id = id
      //  self.partyId = id as! String
        self.name = name
        self.party = party
        //self.coordinate = coordinate
        self.latitude = lat
        self.longitude = long
        self.title = name
        self.creator = creator
        self.participants = participants
      //  self.participants.append(creator)
        self.date = date
        self.type = type
        self.images = []
        self.tittleImage = ""
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
