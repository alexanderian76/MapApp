//
//  ViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 27.01.2021.
//

import UIKit
import MapKit

enum Result<T>{
    case success(T)
    case falure(Error)
}

var parties:Array<Party>! = Array<Party>()
var partyTypes:Array<String> = ["Dancing","Sport","Languages","Games"]

class PartyViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    let cellID = "cellID"
    var currentUser:User! = user
    var http:HTTPCommunication = HTTPCommunication()
    var tmpImages: Array<[String:String]> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
       // http.postUser()
        http.getUser(UserDefault.userName!)
        http.retrieveData(user.partyIds,tableView:tableView)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
       // http.updateUser()
        http.getUser(UserDefault.userName)
        http.retrieveData(user.partyIds,tableView:tableView)

        tableView.reloadData()
        
    }
    //D6FE5297-2D55-49A0-A1F7-6DF3BAF52717


    
}
extension PartyViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return 1
       // return parties.count
        return user.partyIds.count
    }
   // func numberOfSections(in tableView: UITableView) -> Int {
  //      return 1
  //  }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      /*  var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        //print(user.name)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        }

        if(indexPath.row > parties.count - 1){
            cell?.textLabel!.text = ""
        }
        else{
            cell?.textLabel!.text = parties[indexPath.row].name
        }
        
        cell?.imageView!.image = UIImage(named: "image")!
        //print(user.parties[indexPath.row])
       // tableView.reloadData()
 */
        var cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
        if cell == nil {
            cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
        }

        if(indexPath.row > parties.count - 1){
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
            
            cell.imageId = parties[indexPath.row].tittleImage
            DispatchQueue.global(qos: .userInteractive).async {
                cell.loadImage()
                
            }
            
            cell.textLabel!.text = parties[indexPath.row].name
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: parties[indexPath.row].title, message: "", preferredStyle: .actionSheet)
        let partyAction = UIAlertAction(title: "Show party", style: .default){
            (alert) in
            self.performSegue(withIdentifier: "goToProfile", sender: indexPath)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive){
            (alert) in
           // user.parties.remove(at: indexPath.row)
            if(parties[indexPath.row].creator == UserDefault.userName!){
                print("USER CREATOR")
                print(parties[indexPath.row].id!)
                self.http.deleteChat(id: chats.first(where: { (chat:Chat) -> Bool in
                    chat.partyId == parties[indexPath.row].id!
                })!.id!) { [weak self] (data, response, error) in
                    if let response = response{
                        print("RESPONSE DELETE CHAT")
                        print(response)
                }
                }
                self.http.deleteParty(id: parties[indexPath.row].id!) { [weak self] (data, response, error) in
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
                
            }else{
                parties[indexPath.row].participants.remove(at: parties[indexPath.row].participants.firstIndex(of: user.name)!)
                self.http.updateParty(tmpParty: parties[indexPath.row])
            }
            
            user.partyIds.remove(at: indexPath.row)
            self.http.updateUser()
            self.http.retrieveData(user.partyIds, tableView: nil)
            
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            (alert) in
            
            tableView.reloadData()
        }
        alert.addAction(partyAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile"
        {
            let vc = segue.destination as! ProfileViewController
            let indexPath = sender as! IndexPath
            //let party = parties[indexPath.row]
            let party = parties.first(where: { (p) -> Bool in
                p.name == parties[indexPath.row].name
            })
            print("PARTY")
            print(party!.id)
            http.getUser(party?.creator,complition: {[weak self] (data) -> Void in
                    guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
                    
                    print("JSON: ", jsonUser)
                    print(jsonUser)
                         
                do{
                               
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonObject = jsonObjectAny as! [String:Any]
                    let creator = User(name: jsonObject["name"] as! String)
                    vc.creator = creator
                }
                catch{
                    print("Ошибка")
                }
               // self?.tableView.reloadData()
            } )

            vc.party = party
        }
        
    }
}

