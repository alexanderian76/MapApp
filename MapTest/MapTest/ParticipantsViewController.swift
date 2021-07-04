//
//  ParticipantsViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 10.02.2021.
//

import UIKit


class ParticipantsViewController: UIViewController {

    var images: Array<[String:UIImage?]> = []
    @IBOutlet weak var tableView: UITableView!
    let cellID = "cellID"

    var participants:Array<String>!
    var tmpImages: Array<[String:String]> = []
    
    var http:HTTPCommunication = HTTPCommunication()

override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    print(participants)

    http.getUsers(ids: participants) {[weak self] (data) -> Void in
    
    guard let jsonChat = String(data: data, encoding: String.Encoding.utf8) else { return }
    print("JSON USers: ", jsonChat)
    
  
do{
        
let jsonObjectAnyChat: Any = try JSONSerialization.jsonObject(with: data, options: [])
let jsonObjectChat = jsonObjectAnyChat as! [[String:Any]]
   // var tmpUsers:Array<User> = []
    for item in jsonObjectChat{
     //   tmpUsers.append(User(id: item["id"] as! String, name: item["name"] as! String, partyIds: item["partyIds"] as! Array<String>, imageId: item["imageId"] as! String))
        self?.tmpImages.append(["\(item["name"] as! String)" : item["imageId"] as! String])
    }
    self?.tableView.reloadData()
}
catch{
    print("Ошибка")
}
//self?.tableView.reloadData()
}
    
}
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    print(images)
        tableView.reloadData()
    
}





}
extension ParticipantsViewController: UITableViewDelegate, UITableViewDataSource{
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return participants.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
    if cell == nil {
        cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
    }

    if(indexPath.row > participants.count - 1){
        cell.textLabel!.text = ""
        
    }
    else{
       /* if images.first(where: { (data:[String:UIImage?]) -> Bool in
            data.keys.first == participants[indexPath.row]
        }) != nil{
        cell?.imageView!.image = images.first(where: { (data:[String:UIImage?]) -> Bool in
            data.keys.first(where: { (name:String) -> Bool in
                name == participants[indexPath.row]
            }) != nil
        })![participants[indexPath.row]]!
        }
        else{
            cell?.imageView!.image = UIImage()
        }*/
        if tmpImages != []{
        cell.imageId = tmpImages.first(where: { (item:[String:String]) -> Bool in
            item.keys.first == participants[indexPath.row]
        })![participants[indexPath.row]]!
            DispatchQueue.global().async {
                cell.loadImage()
            }
        }
        cell.textLabel!.text = participants[indexPath.row]
        
    }

    return cell
}


}
