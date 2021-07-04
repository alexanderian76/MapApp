//
//  FilterItem.swift
//  MapTest
//
//  Created by Alexander Malygin on 24.02.2021.
//

import Foundation
import UIKit

class FilterItem: UITableViewCell {
    
    @IBOutlet weak var buttonView: UIButton!
    
    @IBOutlet weak var labelView: UILabel!
    
    @IBAction func selectAction(_ sender: Any) {
        flag = !flag
        if flag {
            print(flag)
            buttonView.isSelected = !buttonView.isSelected
           // buttonView.imageView!.image = UIImage(named: "image")
        }
        else{
            print(flag)
            buttonView.isSelected = !buttonView.isSelected
        }
    }
    
    var flag:Bool = false
    public func setFilterCell(cell:String){
      
        self.buttonView.imageView?.image = UIImage(named: "Tick Image")
        self.labelView.text = cell
    }
    
}
