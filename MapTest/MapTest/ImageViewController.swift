//
//  ImageViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 27.02.2021.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    
    var party:Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTapGesture))
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressTap))
        self.view.addGestureRecognizer(panGesture)
        self.view.addGestureRecognizer(longPress)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageView.image = nil
    }
    
    @objc func panTapGesture(){
        print("panGesture")
        navigationController?.popViewController(animated: true)
      //  dismiss(animated: true, completion: nil)
    }

    @objc func longPressTap(){
        let alert = UIAlertController(title: "title", message: "alert", preferredStyle: .actionSheet)
        let partyAction = UIAlertAction(title: "Action", style: .default){ [weak self]
            (alert) in
            guard let image = self?.imageView.image else { return }

            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            (alert) in
        }
        alert.addAction(partyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
