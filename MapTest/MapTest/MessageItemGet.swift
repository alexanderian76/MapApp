//
//  MessageItemGet.swift
//  MapTest
//
//  Created by Alexander Malygin on 14.02.2021.
//

import Foundation
import UIKit


class MessageItemGet: UITableViewCell {
    @IBOutlet weak var senderView: UILabel!
    
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var messageView: UILabel!
    
   // @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var txt: UILabel!
    public func setMessage(message:Dictionary<String,String>){
        self.messageView.layer.masksToBounds = true
        
        
        self.messageView.layer.cornerRadius = 7
       
        
       // self.messageView.backgroundColor = .blue
        self.txt.layer.masksToBounds = true
        self.txt.layer.cornerRadius = 11
        
        
        self.txt.text = message["message"]
        

        self.senderView.text = message["sender"]
      //  self.dateView.text = message["time"]
        self.messageView.text = message["message"]
    }
}
