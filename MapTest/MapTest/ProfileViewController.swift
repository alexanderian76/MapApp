//
//  ProfileViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 28.01.2021.
//

import UIKit

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var countMessages: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    
    @IBOutlet weak var dateView: UILabel!
    // var party:Party!
    @IBOutlet weak var participantsView: UILabel!
    
    @IBOutlet weak var tittleBubble: UILabel!
    @IBOutlet weak var descriptionBubble: UILabel!
    
    @IBOutlet weak var dateBubble: UILabel!
    
    @IBOutlet weak var countPartiBubble: UILabel!
    @IBOutlet weak var buttonPartiBubble: UILabel!
    @IBOutlet weak var chatBubble: UILabel!
    
    
    @IBAction func showParticipants(_ sender: Any) {
        
        let newVC = storyboard?.instantiateViewController(identifier: "ParticipantsViewController") as! ParticipantsViewController
        newVC.loadView()
        
        newVC.participants = party.participants

        newVC.viewDidLoad()
        navigationController?.show(newVC, sender: nil)
        
    }
    
    
    @IBAction func enterChat(_ sender: Any) {
        
        let newVC = storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        newVC.loadView()
        
        //newVC.participants = party.participants
        newVC.partyId = party.id
        newVC.viewDidLoad()
        navigationController?.show(newVC, sender: nil)
        
    }
    
    
    var party:Party!
    var creator:User!
    let imagePicker = UIImagePickerController()
    let http:HTTPCommunication = HTTPCommunication()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        titleView.text = party.name
        descriptionView.text = party.subtitle
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        imageView.addGestureRecognizer(tapGesture)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        
        tittleBubble.layer.masksToBounds = true
        tittleBubble.layer.cornerRadius = 10
        descriptionBubble.layer.masksToBounds = true
        descriptionBubble.layer.cornerRadius = 10
        dateBubble.layer.masksToBounds = true
        dateBubble.layer.cornerRadius = 10
        buttonPartiBubble.layer.masksToBounds = true
        buttonPartiBubble.layer.cornerRadius = 10
        countPartiBubble.layer.masksToBounds = true
        countPartiBubble.layer.cornerRadius = 10
        chatBubble.layer.masksToBounds = true
        chatBubble.layer.cornerRadius = 10
        
        
        dateView.text = party.date
        participantsView.text = String(party.participants.count)
       let chat = chats.first(where: { (chat:Chat) -> Bool in
        chat.partyId == party.id!
        })!
        if unreadMessages[chat.id!] != nil{
        countMessages.text = "New messages: \(String(unreadMessages[chat.id!]!))"
        }
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .default).async {
            
            if self.party.tittleImage != ""{
                self.http.downloadFile(fileId: self.party.tittleImage) { (data:Data) in
                   
                    self.imageView.image = UIImage(data: data)
            }
        }
        }
    }

}
extension ProfileViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let destination = segue.destination as? ImagesCollectionViewController else { return }
          //  destination.delegate = self
        destination.loadView()
        destination.party = party
        destination.viewDidLoad()
        print("loaded")
        
        }
    
    @objc func tapOnImage(_ sender : UITapGestureRecognizer){
        if UserDefault.userName! == party.creator{
        let alert = UIAlertController(title: "Add image", message: "", preferredStyle: .actionSheet)
        let actionPhoto = UIAlertAction(title: "From library", style: .default){
            (alert) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let actionCamera = UIAlertAction(title: "Camera", style: .default){
            (alert) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionPhoto)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
        }
    }

}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = pickedImage
            let id = UUID().uuidString
            party.tittleImage = id
            http.uploadFile(fileData: pickedImage.jpegData(compressionQuality: 0)!, id: id)
            http.updateParty(tmpParty: party)
            dismiss(animated: true, completion: nil)
        }
    }
}
