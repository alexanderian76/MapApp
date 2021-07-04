//
//  ImagesCollectionViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 24.02.2021.
//

import UIKit

class ImagesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addAction(_ sender: Any) {
        
        
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
    
    
    var party:Party!
    let http: HTTPCommunication = HTTPCommunication()
    let imagePicker = UIImagePickerController()
    var flag:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      //  collectionView.frame = view.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        var i = 0
        for item in party.images
       {
            
        (collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as! ImageViewCell).imageView.image = nil
            i += 1
       }
        flag = true
        print("disappeared")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if flag {
            collectionView.reloadData()
            print("Did appeared")
        }
    }

    func loadImage(item:String,index:IndexPath){
            http.downloadFile(fileId: item, complition: { [self] (data) -> Void in
        do{
            (collectionView.cellForItem(at: index) as! ImageViewCell).imageView.image = UIImage(data: data)
        }
        catch{
            print("Mistake in downloading")
        }
            })
        }
    
    
}

extension ImagesCollectionViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        party.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.identifier, for: indexPath) as! ImageViewCell
        
            cell.imageId = party.images[indexPath.row]
        DispatchQueue.global(qos: .userInteractive).async {
            cell.loadImage()
        }
       // loadImage(item: party.images[indexPath.item], index: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width/3) - 3, height: (view.frame.size.height/6) - 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newVC = storyboard?.instantiateViewController(identifier: "ImageViewController") as! ImageViewController
        newVC.loadView()
        
        newVC.party = party
        newVC.imageView.image = (collectionView.cellForItem(at: indexPath) as! ImageViewCell).imageView.image
        newVC.viewDidLoad()
       // navigationController?.present(newVC, animated: true, completion: nil)
        navigationController?.show(newVC, sender: nil)
    }
    

    
}
extension ImagesCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //imageView.image = pickedImage
            let id = UUID().uuidString
           // http.uploadFile(fileData: pickedImage.jpegData(compressionQuality: 0)!, id: id)
            var request = URLRequest(url: URL(string: "http://localhost:8080/upload?key=\(id).jpg")!)
            request.httpMethod = "POST"
            request.httpBody = pickedImage.jpegData(compressionQuality: 0)!

            let task = URLSession.shared.uploadTask(with: request, from: request.httpBody!){ [weak self](data, response, error) in
                DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.dismiss(animated: true, completion: nil)
                }
            }
            task.resume()
            party.images.append(id)
            http.updateParty(tmpParty: party)
            
            
            
        }
    }
}
