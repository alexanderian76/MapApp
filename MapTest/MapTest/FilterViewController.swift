//
//  FilterViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 24.02.2021.
//

import UIKit

class FilterViewController: UIViewController {

    weak var delegate : SearchEventsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func filterAction(_ sender: Any) {
        filter()
        delegate?.filterData(data: types)
    }
    
    @IBOutlet weak var filterButton: UIButton!
    
    var types: Array<String> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        filterButton.layer.masksToBounds = true
        filterButton.layer.cornerRadius = 30
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for cell in tableView.visibleCells{
            print((cell as! FilterItem).labelView.text!)
            if types.contains((cell as! FilterItem).labelView.text!){
                (cell as! FilterItem).buttonView.isSelected = true
            }
        }
    }
 
    func filter(){
        types = []
        for cell in self.tableView.visibleCells{
            if (cell as! FilterItem).buttonView.state == .selected{
                types.append((cell as! FilterItem).labelView.text!)
            }
        }
    }
    
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        partyTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibs: Array =  Bundle.main.loadNibNamed("FilterSelectedCell", owner: nil, options: nil)!
        let nib: FilterItem = nibs[0] as! FilterItem
        
        nib.setFilterCell(cell: partyTypes[indexPath.row])
        
       
        
        return nib
    }
    
    
    
}
