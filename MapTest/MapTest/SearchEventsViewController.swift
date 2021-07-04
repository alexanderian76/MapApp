//
//  SearchEventsViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 18.02.2021.


import UIKit
import MapKit
import NotificationCenter


protocol SearchEventsViewControllerDelegate: class {
    func filterData(data: Array<String>)
}

class SearchEventsViewController: UIViewController, UISearchBarDelegate, SearchEventsViewControllerDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchView: UISearchBar!
    
    
    @IBAction func filterView(_ sender: Any) {
     //   let newVC = storyboard?.instantiateViewController(identifier: "FilterViewController") as! FilterViewController
     //   newVC.loadView()
        
        //newVC.participants = party.participants
        
      //  newVC.viewDidLoad()
      //  navigationController?.showDetailViewController(newVC, sender: nil)
    }
    
    
    let cellID = "cellID"
   // var currentUser:User! = user
    var searchedParties: Array<Party> = []
    var http:HTTPCommunication = HTTPCommunication()
    var types: Array<String> = partyTypes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        //http.getUser(UserDefault.userName!)
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        //self.tableView.addGestureRecognizer(tapGesture)
    //    self.view.removeGestureRecognizer(tapGesture)
        
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        http.retrieveParties( nil, tableView: nil) {
            [weak self] (data) -> Void in
            guard let json = String(data: data, encoding: String.Encoding.utf8) else { return }
            do {
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonObject = jsonObjectAny as! [[String:Any]]
                parties = []
                self?.searchedParties = []
                    for item in jsonObject{
                        parties.append(Party(id : item["id"] as! String, name: item["name"] as! String, party: item["party"] as! String, coordinate: CLLocationCoordinate2D(latitude: item["latitude"] as! Double, longitude: item["longitude"] as! Double), creator: item["creator"] as! String, participants: item["participants"] as! Array<String>, date: item["date"] as! String, type: item["type"] as! String, tittleImage: item["tittleImage"] as! String, images: item["images"] as! Array<String>))
                }
                for party in parties
                {
                    if self!.types.contains(party.type){
                        self?.searchedParties.append(party)
                    }
                }
                self?.tableView.reloadData()
            }
            catch {
                print("Can't serialize data.")
            }
        }
        
    }
    
    
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(sender : NSNotification)
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
       
    }
    
    @objc func keyboardWillHide(sender:NSNotification){
        print(self.view.gestureRecognizers?.count)
       // print(self.view.gestureRecognizers)
        if self.view.gestureRecognizers != nil{
        for item in self.view.gestureRecognizers!{
        self.view.removeGestureRecognizer(item)
        }
    }
            
    }
    
    
    func filterData(data: Array<String>) {
        types = data
        searchedParties = []
        for party in parties
        {
            if types.contains(party.type){
                searchedParties.append(party)
            }
        }
        print("filter saved")
        tableView.reloadData()
    }
    
}
extension SearchEventsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedParties.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
        if cell == nil {
            cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
        }

        if(indexPath.row > parties.count - 1){
            cell.textLabel!.text = ""
            
        }
        else{
            cell.textLabel!.text = self.searchedParties[indexPath.row].name
        }
        cell.imageId = parties[indexPath.row].tittleImage
        DispatchQueue.global(qos: .userInteractive).async {
            cell.loadImage()
            
        }
      //  cell.imageView!.image = UIImage(named: "image")!
        //print(user.parties[indexPath.row])
       // tableView.reloadData()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let newVC = self.storyboard?.instantiateViewController(identifier: "EventViewController") as! EventViewController
           // navigationController?.pushViewController(newVC!, animated: true)
            newVC.loadView()
            
            newVC.party = self.searchedParties[indexPath.row]
            newVC.titleView.text = self.searchedParties[indexPath.row].name
            newVC.creatorView.text = self.searchedParties[indexPath.row].creator
            newVC.participantsView.text = String((self.searchedParties[indexPath.row].participants.count))
            newVC.descriptionView.text = self.searchedParties[indexPath.row].subtitle
            newVC.viewDidLoad()
            self.navigationController?.showDetailViewController(newVC, sender: nil)
       
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchedParties = []
            for party in parties
            {
                if types.contains(party.type){
                    searchedParties.append(party)
                }
            }
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        searchedParties = []
        if(searchText != ""){
        for party in parties
        {
            if party.name.lowercased().contains(searchText.lowercased()) && types.contains(party.type){
                searchedParties.append(party)
            }
        }
        }
        else{
            for party in parties
            {
                if types.contains(party.type){
                    searchedParties.append(party)
                }
            }
            
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let destination = segue.destination as? FilterViewController else { return }
            destination.delegate = self
        destination.loadView()
        destination.types = types
        print(types)
        destination.viewDidLoad()
        print("loaded")
        
        }
}

