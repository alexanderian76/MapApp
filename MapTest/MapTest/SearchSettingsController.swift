import UIKit

struct res{
    
    var Name:String!
    var Info:String!
    var Date:String!
    var PartyType:String!
}

class SearchSettingsController: UIViewController {

    
    @IBOutlet weak var partyName: UITextField!
 
    @IBOutlet weak var partyInfo: UITextField!
    
    @IBOutlet weak var dateView: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var bubbleSaveButton: UILabel!
    @IBOutlet weak var bubbleParty: UILabel!
    @IBOutlet weak var bubbleDespription: UILabel!
    @IBOutlet weak var bubbleDate: UILabel!
    @IBOutlet weak var bubblePicker: UILabel!
    
    @IBOutlet weak var typeBubble: UILabel!
    
    @IBOutlet weak var typeView: UITextField!
    
    weak var delegate: MapViewControllerDelegate?
   // let datePicker = UIDatePicker()
    //let datePicker = datePickerView
    
    @IBAction func changeDataInFirstVC() {
        if partyTypes.contains(typeView.text ?? ""){
        delegate?.update(data: res(Name: partyName.text, Info: partyInfo.text, Date: dateView.text, PartyType: typeView.text))
        }
        else{
            print("Mistake in party type")
        }
        }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bubbleSaveButton.layer.masksToBounds = true
        bubbleSaveButton.layer.cornerRadius = 10
        bubbleParty.layer.masksToBounds = true
        bubbleParty.layer.cornerRadius = 10
        bubbleDespription.layer.masksToBounds = true
        bubbleDespription.layer.cornerRadius = 10
        bubbleDate.layer.masksToBounds = true
        bubbleDate.layer.cornerRadius = 10
        bubblePicker.layer.masksToBounds = true
        bubblePicker.layer.cornerRadius = 10
        typeBubble.layer.masksToBounds = true
        typeBubble.layer.cornerRadius = 10
       // bubbleSaveButton.alpha = 1
        
        dateView.isHidden = true
        //dateView.inputView = datePicker
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
      //  picker.translatesAutoresizingMaskIntoConstraints = false
     //   view.addSubview(picker)
        typeView.inputView = picker
        
        
        datePicker.datePickerMode = .dateAndTime
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        //toolbar.sizeThatFits(self.preferredContentSize)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexSpace,doneButton], animated: true)
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        
        self.view.addGestureRecognizer(tapGesture)
      //  titleView.text = party.name
     //   descriptionView.text = user.partyIds[0]
      //  UINavigationItem.setLeftBarButton(backButton)
        //backButton.leftBarButtonItem?.action = self.performSegue(withIdentifier: "goToSettings", sender: res(Name: partyName, Info: partyInfo))
    }
    
    @objc func doneAction(){
        view.endEditing(true)
    }
    
    @objc func dateChanged(){
        getDateFromPicker()
    }
    
    @objc func tapGestureDone(){
        view.endEditing(true)
    }
    
    func getDateFromPicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateView.text = formatter.string(from: datePicker.date)
    }

}
extension SearchSettingsController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToSettings"
    {
        let vc = segue.source as! MapViewController
        let indexPath = sender as! IndexPath
        //let party = parties[indexPath.row]
        let party = user
        vc.partyName = (sender as! res).Name
        vc.partyInfo = (sender as! res).Info
        vc.dateInfo = (sender as! res).Date
        vc.partyType = (sender as! res).PartyType
    }
    
}

}

extension SearchSettingsController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return partyTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            typeView.text = partyTypes[row]
            return partyTypes[row]
        }
        else
        {
            typeView.text = partyTypes[row]
            return partyTypes[row]
        }
    }
}
