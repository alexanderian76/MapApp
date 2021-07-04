//
//  EventViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 10.02.2021.
//

import UIKit


class EventViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var creatorView: UILabel!
    @IBOutlet weak var participantsView: UILabel!
    
    @IBOutlet weak var descriptionView: UITextView!
    
    @IBOutlet weak var descriptionBubble: UILabel!
    @IBOutlet weak var tittleBubble: UILabel!
    @IBOutlet weak var countPartiBubble: UILabel!
    @IBOutlet weak var creatorBubble: UILabel!
    @IBOutlet weak var participantsBubble: UILabel!
    var party:Party!
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addParty(_ sender: Any) {
        let http:HTTPCommunication = HTTPCommunication()
        user.partyIds.append(party.id!)
        addButton.isEnabled = false
        party.participants.append(user.name)
        http.updateUser()
       // http.retrieveData(user.partyIds, tableView: nil)
        http.updateParty(tmpParty: party)
        http.loadChats(ids: user.partyIds) {[weak self] (data) -> Void in
            guard let jsonChat = String(data: data, encoding: String.Encoding.utf8) else { return }
        do{
        let jsonObjectAnyChat: Any = try JSONSerialization.jsonObject(with: data, options: [])
        let jsonObjectChat = jsonObjectAnyChat as! [[String:Any]]
            var tmpChats:Array<Chat> = []
            for item in jsonObjectChat{
                tmpChats.append(Chat(id: item["id"] as! String?, messages: item["messages"] as! Array<Dictionary<String,String>>, partyId: item["partyId"] as! String))
            }
         chats = tmpChats
        
        }
        catch{
            print("Ошибка")
        }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tittleBubble.layer.masksToBounds = true
        tittleBubble.layer.cornerRadius = 10
        descriptionBubble.layer.masksToBounds = true
        descriptionBubble.layer.cornerRadius = 10
        creatorBubble.layer.masksToBounds = true
        creatorBubble.layer.cornerRadius = 10
        participantsBubble.layer.masksToBounds = true
        participantsBubble.layer.cornerRadius = 10
        countPartiBubble.layer.masksToBounds = true
        countPartiBubble.layer.cornerRadius = 10
        if(party.participants.contains(UserDefault.userName!)){
            addButton.isEnabled = false
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

