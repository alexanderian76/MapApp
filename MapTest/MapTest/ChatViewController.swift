//
//  ChatViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 13.02.2021.
//

import Foundation
import UIKit
import NotificationCenter

var unreadMessages: Dictionary<String,Int> = [:]

class ChatViewController: UIViewController {
    
    
    var partyId:String!
    var chat:Chat = Chat(id: nil, messages: [], partyId: "")

    @IBOutlet weak var senderCell: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageView: UITextView!
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBAction func sendMessage(_ sender: Any) {
     //   http.updateChat(chat: Chat(id: chat.id!, messages: [["chat": chat.id!, "message": messageView.text, "sender": UserDefault.userName!]], partyId: chat.partyId), index: String(chat.messages.count), tableView: self.tableView)
       // tableView.reloadData()
        if messageView.text != ""
        {
        http.sendMessage(chat: chat, message: messageView.text)
        print(chat.messages.count)
        messageView.text = ""
        }
    }
    
    
    
    let http:HTTPCommunication = HTTPCommunication()
    var heightCell:CGFloat = CGFloat()
 //   var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        messageView.layer.cornerRadius = 15
        print("ID CHAT")
      //  print(chat.id!)
        chat = chats.first(where: { (chat:Chat) -> Bool in
            chat.partyId == partyId
        })!
        http.setupWebSocket(chat:chat, tableView: self.tableView)
        http.sendMessage(chat: Chat(id: "", messages: [], partyId: ""), message: "")
     //   NotificationCenter.default.addObserver(self, selector: #selector(scrollToBot), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       // refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
      //  refreshControl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
       // self.tableView.addSubview(refreshControl)
     //   reload()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unreadMessages[chat.id!] = 0
     //   http.closeSocket()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        unreadMessages[chat.id!] = 0
       
        
        print("NUMBER OF MESSAGES")
        print(chat.messages.count)
        self.tableView.estimatedRowHeight = 112
            self.tableView.rowHeight = UITableView.automaticDimension
        http.getChat(chat.id!, index: String(chat.messages.count)) {[weak self] (data) -> Void in
            
            guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
         //   print("JSON CHAT: ", jsonUser)
           // print(jsonUser)
          
        do{
                
        let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
        let jsonObject = jsonObjectAny as! [String:Any]
            print("MESSAGES")
            print(jsonObject["messages"] as! Array<Dictionary<String,String>>)
         chats.first { (chat:Chat) -> Bool in
                chat.partyId == jsonObject["partyId"] as! String
         }?.messages.append(contentsOf: jsonObject["messages"] as! Array<Dictionary<String,String>>)
          //  self?.chat.messages.append(contentsOf: jsonObject["messages"] as! Array<Dictionary<String,String>>)
            
        }
        catch{
            print("Ошибка")
        }
        self?.tableView.reloadData()
            if (self?.chat.messages.count)! > 1{
        self?.tableView?.scrollToRow(at: IndexPath(item: (self?.chat.messages.count)!-1, section: 0), at: .bottom, animated: true)
            }
    }
    }
    
    
    @objc func scrollToBot(sender : NSNotification){
        self.tableView?.scrollToRow(at: IndexPath(item: (self.chat.messages.count)-1, section: 0), at: .bottom, animated: true)
    }
    
    var t:CGFloat = CGFloat()
    
    @objc func keyboardWillShow(sender : NSNotification)
    {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if t == CGFloat(){
            t = keyboardSize.height
                self.senderCell.frame.origin.y -= keyboardSize.height
                self.tableView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(sender:NSNotification){
        self.senderCell.frame.origin.y += t
        self.tableView.frame.origin.y += t
        t = CGFloat()
            
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), for: UIControl.Event.valueChanged)
        
        return refreshControl
    }()
    
    @objc func reload(){
        refreshControl.beginRefreshing()
        self.viewDidAppear(true)
        http.getChat(chat.id!, index: String(chat.messages.count)) {[weak self] (data) -> Void in
            
            guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
        //    print("JSON CHAT: ", jsonUser)
         //   print(jsonUser)
          
        do{
                
        let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
        let jsonObject = jsonObjectAny as! [String:Any]
            print("MESSAGES")
            print(jsonObject["messages"])
         chats.first { (chat:Chat) -> Bool in
                chat.id == jsonObject["partyId"] as! String
         }?.messages = jsonObject["messages"] as! Array<Dictionary<String,String>>
            
            self?.chat.messages = chats.first { (chat:Chat) -> Bool in
                chat.partyId == jsonObject["partyId"] as! String
            }!.messages
           
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
            self?.tableView?.scrollToRow(at: IndexPath(item: (self?.chat.messages.count)!-1, section: 0), at: .bottom, animated: true)
            
        }
        catch{
            print("Ошибка")
        }
        
    }
    }
    
    
    
}
extension ChatViewController:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chat.messages[indexPath.row]["sender"] == UserDefault.userName!{
            let nibs: Array =  Bundle.main.loadNibNamed("messageSend", owner: nil, options: nil)!
            let nib: MessageItemSend = nibs[0] as! MessageItemSend
            
            nib.setMessage(message: ["chat": chat.id!, "message": chat.messages[indexPath.row]["message"]!, "sender": chat.messages[indexPath.row]["sender"]!])
            
           
            
            return nib
        }
        else{
            let nibs: Array =  Bundle.main.loadNibNamed("messageGet", owner: nil, options: nil)!
            let nib: MessageItemGet = nibs[0] as! MessageItemGet
            
            nib.setMessage(message: ["chat": chat.id!, "message": chat.messages[indexPath.row]["message"]!, "sender": chat.messages[indexPath.row]["sender"]!])
            return nib
        }
       

        //return nib
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        return UITableView.automaticDimension
    }
}


