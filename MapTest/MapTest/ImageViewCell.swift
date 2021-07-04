//
//  ImageViewCellCollectionViewCell.swift
//  MapTest
//
//  Created by Alexander Malygin on 24.02.2021.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    
    static let identifier = "imageCell"
    
    var imageId:String = ""
    
    let http:HTTPCommunication = HTTPCommunication()
    var request: URLRequest!
    var task: URLSessionDataTask!
    
    func loadImage(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.imageView.image = nil
        })
        task?.cancel()
        print("loading")
        print(imageId)
        if let image = cache[imageId] {
            DispatchQueue.main.async(execute: { () -> Void in
                self.imageView.image = image
            })
        }
        else{
            request = URLRequest(url: URL(string: "http://127.0.0.1:8080/download/\(imageId).jpg")!)
            task = URLSession.shared.dataTask(with: request) { [self] (data,resp,error) -> Void in
    do {
        var jpg = UIImage(data: data!)?.jpegData(compressionQuality: 0)
        DispatchQueue.global(qos: .userInteractive).async(execute: { () -> Void in
           print("load from URL")
            print(data)
            DispatchQueue.main.async(execute: { () -> Void in
            self.imageView.image = UIImage(data: jpg!, scale: 10)
            })
            cache[imageId] = UIImage(data: jpg!, scale: 10)
            
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
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.addSubview(imageView)
        //let images = [UIImage(named: "image")].compactMap({ $0 })
       // imageView.image = images.randomElement()
      //  loadImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
            //   imageView.image = nil
    }
}
