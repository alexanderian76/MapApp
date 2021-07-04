//
//  UserViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 28.01.2021.
//

import UIKit

let cache = ImageCache()


class UserViewController: UIViewController {


    
    var signup:Bool = true{
        willSet{
            if newValue{
                labelView.text = "Регистрация"
                enterButton.setTitle("Регистрация", for: .normal)
                repeatPasswordView.isHidden = false
            }
            else{
                labelView.text = "Вход"
                enterButton.setTitle("Вход", for: .normal)
                repeatPasswordView.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var logview: UIView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    @IBOutlet weak var repeatPasswordView: UITextField!
    
    
    @IBOutlet weak var tittleBubble: UILabel!
    @IBOutlet weak var countPartiBubble: UILabel!
    @IBOutlet weak var partiesBubble: UILabel!
    
    
    var effect: UIVisualEffect!

    var newUser:Bool = false{
        willSet{
            if newValue{
                self.view.subviews.last?.isHidden = true
                //self.visualEffect.removeFromSuperview()
                self.visualEffect.effect = nil
                self.visualEffect.alpha = 0
                
                self.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    @IBAction func exitAction(_ sender: UIButton) {
        UserDefault.userName = nil
        UserDefault.userPassword = nil
        self.view.subviews.last?.isHidden = false
        self.visualEffect.effect = self.effect
        self.visualEffect.alpha = 1
    animateIn()
        self.tabBarController?.tabBar.isHidden = true
        self.view.reloadInputViews()
    }
    @IBAction func enterData(_ sender: UIButton) {
        let http: HTTPCommunication! = HTTPCommunication()
        user.name = loginView.text!
        user.password = passwordView.text!
        print(user.password)
        //http.postUser()
        print(user.name)
       // http.getUser(user.name)
        if user.name != nil && user.name != "" {
        http.getUser(user.name,complition: {[weak self] (data) -> Void in
                
                
                guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
                
                print("JSON: ", jsonUser)
                print(jsonUser)
            
            
            
            do{
                
            
            let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonObject = jsonObjectAny as! [String:Any]
                if (self!.signup){
                    if(jsonObject["name"] as! String == "" && self?.passwordView.text == self?.repeatPasswordView.text){
          //  user.name = jsonObject["name"] as! String
                        
            user.partyIds = jsonObject["partyIds"] as! Array<String>
           // UserDefault.userName = jsonObject["name"] as! String
          //  UserDefault.userPassword = jsonObject["password"] as! String
                    UserDefault.userName = user.name
                    UserDefault.userPassword = user.password
               // self?.http.retrieveData(user.partyIds, tableView: nil)
                self?.countView.text = String(user.partyIds.count)
                self?.nameView.text = user.name
                self?.view.reloadInputViews()
                    http.postUser()
                    self?.newUser = true
                       
                }
                else{
                    print("Такое имя уже есть")
                    self?.newUser = false
                }
                }
                else{
                    if(jsonObject["name"] as! String == user.name && jsonObject["password"] as! String == user.password){
                        user.partyIds = jsonObject["partyIds"] as! Array<String>
                        UserDefault.userName = user.name
                        UserDefault.userPassword = user.password
                        self?.countView.text = String(user.partyIds.count)
                        self?.nameView.text = user.name
                        user.imageId = jsonObject["imageId"] as! String
                        if user.imageId != "" {
                            self?.http.downloadFile(fileId: user.imageId, complition: { (data) -> Void in
                            do{
                                print(data)
                                self?.imageView.image = UIImage(data: data)
                            }
                            catch{
                                print("Mistake in downloading")
                            }
                        })
                        }
                        if(user.partyIds.count > 0){
                            self?.http.loadChats(ids: user.partyIds) {[weak self] (data) -> Void in
                            
                            guard let jsonChat = String(data: data, encoding: String.Encoding.utf8) else { return }
                            print("JSON CHAT: ", jsonChat)
                            print(jsonUser)
                          
                        do{
                                
                        let jsonObjectAnyChat: Any = try JSONSerialization.jsonObject(with: data, options: [])
                        let jsonObjectChat = jsonObjectAnyChat as! [[String:Any]]
                            var tmpChats:Array<Chat> = []
                            for item in jsonObjectChat{
                                tmpChats.append(Chat(id: item["id"] as! String?, messages: item["messages"] as! Array<Dictionary<String,String>>, partyId: item["partyId"] as! String))
                            }
                         chats = tmpChats
                            print(chats[0])
                        }
                        catch{
                            print("Ошибка")
                        }
                        //self?.tableView.reloadData()
                        }
                    }
                        self?.view.reloadInputViews()
                        self?.newUser = true
                    }
                    else{
                        print("Неверные логин и пароль")
                        self?.newUser = false
                    }
                }
            }
            catch{
                print("Ошибка")
            }
            
            
           // self?.tableView.reloadData()
        } )}
        else{
            print("Enter USERNAME")
        }
        //self.logview.alpha = 0
    //    self.visualEffect.effect = nil
      /*  if newUser {
        self.view.subviews.last?.isHidden = true
        self.visualEffect.removeFromSuperview()
        
        self.tabBarController?.tabBar.isHidden = false
        }
        */
        
       // imagePicker.delegate = self
    }
    
    @IBAction func switchButton(_ sender: UIButton) {
        signup = !signup
    }
     
    
    func animateIn(){
        self.view.addSubview(logview)
        logview.center = self.view.center
        
        logview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        logview.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.logview.alpha = 1
            self.logview.transform = CGAffineTransform.identity
        }
    }
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var countView: UILabel!
    let imagePicker = UIImagePickerController()
    
    var http:HTTPCommunication! = HTTPCommunication()
    
    
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  UserDefault.userName = nil
        effect = visualEffect.effect
        visualEffect.effect = nil
        logview.layer.cornerRadius = 10
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_ :)))
        self.view.addGestureRecognizer(tapGesture2)
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        
        tittleBubble.layer.masksToBounds = true
        tittleBubble.layer.cornerRadius = 10
        countPartiBubble.layer.masksToBounds = true
        countPartiBubble.layer.cornerRadius = 10
        partiesBubble.layer.masksToBounds = true
        partiesBubble.layer.cornerRadius = 10
        
        imagePicker.delegate = self
        if( UserDefault.userName == nil || UserDefault.userName! == "" || UserDefault.userPassword == nil || UserDefault.userPassword! == "" ){
            self.visualEffect.effect = self.effect
        animateIn()
            self.tabBarController?.tabBar.isHidden = true}
        else{
            self.view.subviews.last?.isHidden = true
            //print(UserDefault.userName!)
           // http.getUser(UserDefault.userName!)
            //print("IDS COUNT")
            //print(user.partyIds.count)
            //http.retrieveData(user.partyIds, tableView: nil)
            //countView.text = String(user.partyIds.count)
            //nameView.text = user.name
            imagePicker.delegate = self
            
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Это сайнап")
        print(signup)
        if(UserDefault.userName != nil && UserDefault.userName!.count > 0)  {
        print(UserDefault.userName!)
        //http.getUser(UserDefault.userName!)
        http.getUser(UserDefault.userName!,complition: {[weak self] (data) -> Void in
                
                
                guard let jsonUser = String(data: data, encoding: String.Encoding.utf8) else { return }
                
                print("JSON: ", jsonUser)
                print(jsonUser)
            
            
            
            do{
                
            
            let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonObject = jsonObjectAny as! [String:Any]
                
            
            user.name = jsonObject["name"] as! String
            user.partyIds = jsonObject["partyIds"] as! Array<String>
            user.imageId = jsonObject["imageId"] as! String
                if(jsonObject["name"] as! String == "" || jsonObject["password"] as! String == ""){
                    self?.visualEffect.effect = self?.effect
                    self?.animateIn()
                    self?.tabBarController?.tabBar.isHidden = true
                }
                else{
                    user.id = jsonObject["id"] as! String
                }
                print(user.partyIds)
            UserDefault.userName = jsonObject["name"] as! String
            UserDefault.userPassword = jsonObject["password"] as! String
             //   self?.http.retrieveData(user.partyIds, tableView: nil)
                self?.countView.text = String(user.partyIds.count)
                self?.nameView.text = user.name
                if user.imageId != "" {
                    if let image = cache[user.imageId] {
                        self?.imageView.image = image
                        print("Image from cache")
                        print(image.pngData()?.count)
                    }
                    else{
                    self?.http.downloadFile(fileId: user.imageId, complition: { (data) -> Void in
                    do{
                        print(data)
                        DispatchQueue.main.async {
                        
                        self?.imageView.image = UIImage(data: data)
                            cache[user.imageId] = UIImage(data: data)
                        }
                        
                    }
                    catch{
                        print("Mistake in downloading")
                    }
                })
                    }
                }
                else{
                    self?.imageView.image = UIImage(named: "image")
                }
                if(user.partyIds.count > 0){
                    self?.http.loadChats(ids: user.partyIds) {[weak self] (data) -> Void in
                    
                    guard let jsonChat = String(data: data, encoding: String.Encoding.utf8) else { return }
                    print("JSON CHAT: ", jsonChat)
                    print(jsonUser)
                  
                do{
                        
                let jsonObjectAnyChat: Any = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonObjectChat = jsonObjectAnyChat as! [[String:Any]]
                    var tmpChats:Array<Chat> = []
                    for item in jsonObjectChat{
                        tmpChats.append(Chat(id: item["id"] as! String?, messages: item["messages"] as! Array<Dictionary<String,String>>, partyId: item["partyId"] as! String))
                    }
                 chats = tmpChats
                    print(chats[0])
                }
                catch{
                    print("Ошибка")
                }
                //self?.tableView.reloadData()
                }
            }
            }
            catch{
                print("Ошибка")
            }
           // self?.tableView.reloadData()
        } )
                
       
        }
        
    }
    
    
    @objc func tapOnImage(_ sender : UITapGestureRecognizer){
        
        
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
extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = pickedImage
            let id = UUID().uuidString
            user.imageId = id
            http.uploadFile(fileData: pickedImage.jpegData(compressionQuality: 0)!, id: id)
            http.updateUser()
            dismiss(animated: true, completion: nil)
        }
    }
}
