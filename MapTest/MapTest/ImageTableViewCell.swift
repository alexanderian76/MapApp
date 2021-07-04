//
//  ImageTableViewCell.swift
//  MapTest
//
//  Created by Alexander Malygin on 25.02.2021.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    static let identifier = "imageCell"
    
    var imageId:String = ""
    let http:HTTPCommunication = HTTPCommunication()
   // var task:()!
    var request: URLRequest!
    var task: URLSessionDataTask!
    
    
    func loadImage(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.imageView?.image = nil
        })
        task?.cancel()
        print("loading")
        print(imageId)
        if let image = cache[imageId] {
            DispatchQueue.main.async(execute: { () -> Void in
                self.imageView!.image = image
            })
            print("Image from cache")
            print(image.pngData()?.count)
        }
        else{
            request = URLRequest(url: URL(string: "http://127.0.0.1:8080/download/\(imageId).jpg")!)
            task = URLSession.shared.dataTask(with: request)
            
          //  task = http.downloadFile(fileId: imageId, complition:
                                        { [self] (data,resp,error) -> Void in
    do{
        var jpg = UIImage(data: data!)?.jpegData(compressionQuality: 0)
        DispatchQueue.global(qos: .userInteractive).async(execute: { () -> Void in
           print("load from URL")
            print(data)
            
            DispatchQueue.main.async(execute: { () -> Void in
                if jpg != nil{
            self.imageView!.image = UIImage(data: jpg!, scale: 10)
                }
            })
            if jpg != nil{
            cache[imageId] = UIImage(data: jpg!, scale: 10)
            }
          //  self.loadImage()
            
        })
    }
    catch{
        print("Mistake in downloading")
    }
        }
            task.resume()
        }
    }
    
   /* var imageViewCell: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()*/
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //contentView.addSubview(imageView)
        imageView?.layer.masksToBounds = true
       // imageView?.layer.frame.origin.x = 10
       // imageView?.layer.frame.origin.y = 10
        imageView?.image = UIImage(named: "image")
        
        imageView?.layer.cornerRadius = 10
    }
    
    

    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
            //   imageView.image = nil
    }
}
