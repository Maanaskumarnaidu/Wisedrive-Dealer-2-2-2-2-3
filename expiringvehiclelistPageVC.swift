//
//  expiringvehiclelistPageVC.swift
//  Wisedrive Dealer
//
//  Created by Maanas Kumar on 19/10/22.
//

import UIKit
import Alamofire

class expiringvehiclelistPageVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var totalexpiringvehlistTableView: UITableView!
    
    var exevehlistarr = [ExpiringVehListModelClass]()
    
    var finalString = ""
    
    var nextpageurl = 1
   // var BrandPopupSelectionVCProtocalDelegate : BrandPopupSelectionVCProtocal?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expirevehlistServiceCall(Search: "")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
              let string1 = string
              let string2 = searchTextField.text
              
              if string.length > 0 { // if it was not delete character
                  finalString = string2! + string1
              }
              else if (string2?.length)! > 0{ // if it was a delete character
           
                  finalString = String(string2!.dropLast())
               }
              if finalString.length > 2 {
                  self.expirevehlistServiceCall(Search: finalString)
                  
              }else if finalString.length == 0{
               
                  self.expirevehlistServiceCall(Search: finalString)
                 
              }

      //        filteredArray(finalString)// pass the search String in this method
              return true
          }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
       
        self.expirevehlistServiceCall(Search: "")
       
        return true
    }
    
    
    func expirevehlistServiceCall(Search: String) {
        if !InternetReachable.ValidateInternet {
            Message.NoInternetAlert(self)
            return
        }
        let imei = UIDevice.current.clientID
        //        let userid = SessionHelperClass().getUserId()!
      //  self.activityloader.isHidden = false
            self.view.StartLoading()
        let profiledata = JSON(UserDefaults.standard.value(forKey: "LoginResponse") ?? "{}")
        //                let cityid = UserDefaults.standard.value(forKey: "cityId")
        let data = profiledata.dictionaryObject!
        let dealer_id = data["dealer_id"] as! Int
        
        Webservice().call(cRequest: CRequest.getRequest(url: CUrls.BaseUrl, suffix: CUrls.homepage.get_GetExpiringVehList, method: .get, contentType: .urlencode, params: ["dealerId":dealer_id,"pageNo":"1","search":Search], headers: ["Authorization": "Bearer " ,"X-Device-Imei":imei,"Content-Type":"application/json"])) { (response, auth) in
            
                self.view.StopLoading()
        //    self.activityloader.isHidden = true

            if auth {
                sectionExpiredClass.ClearData(controller: self)
            }
            else {
                self.exevehlistarr.removeAll()
                self.nextpageurl = 1
                switch response.result {
                
                case .success(let jsonResponse):
                    
                    if jsonResponse.responseType.isSuccess {
                        
                        print("get_DealershipMenu_getInspectionHistory:" + "\(jsonResponse.response)");
                        
                        let main = jsonResponse.response.dictionaryValue
                        
                        let ExpiringVehList = main["ExpiringVehList"]?.arrayValue
                        
                        
                       // self.statusid = serviceList!["id"] as! Int
                        ExpiringVehList!.forEach({ (obj) in
                            self.exevehlistarr.append(ExpiringVehListModelClass.init(data: obj))
                        })
                        
                        self.totalexpiringvehlistTableView.reloadData()
                        if ExpiringVehList?.count == 0 {
                            self.nextpageurl = 0
                        }else{
                            self.nextpageurl += 1
                        }
                    } else {
                        
                        if let code = response.response?.statusCode {
                            if code == 401 || code == 403{
                                sectionExpiredClass.ClearData(controller: self)
                                
                            }
                        }
                        
                        print("post_dashBoardHome_homeTabService :" + "\(jsonResponse)")
                        //                        self.view.ShowBlackTostWithText(message: jsonResponse.responseMessage, Interval: 2)
                        self.view.ShowBlackTostWithText(message: jsonResponse.response["message"].stringValue, Interval: 3)
                        
                    }
                    
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    //                    Message.SomethingWrongAlert(self)
                    
                    if let code = response.response?.statusCode {
                        if code == 401 {
                            
                        }
                    }
                    
                    break
                }
            }
        }
    }
    
    func nextpageexpirevehlistServiceCall()  {
        if !InternetReachable.ValidateInternet {
            Message.NoInternetAlert(self)
            return
        }
        let imei = UIDevice.current.clientID
        //        let userid = SessionHelperClass().getUserId()!
        self.view.StartLoading()

        
        let profiledata = JSON(UserDefaults.standard.value(forKey: "LoginResponse") ?? "{}")
        //                let cityid = UserDefaults.standard.value(forKey: "cityId")
        let data = profiledata.dictionaryObject!
        let dealer_id = data["dealer_id"] as! Int

        
        Webservice().call(cRequest: CRequest.getRequest(url: CUrls.BaseUrl, suffix: CUrls.homepage.get_GetExpiringVehList, method: .get, contentType: .urlencode, params: ["dealerId":dealer_id,"pageNo":nextpageurl,"search":self.searchTextField.text!], headers: ["Authorization": "Bearer " ,"X-Device-Imei":imei,"Content-Type":"application/json"])) { (response, auth) in
            self.view.StopLoading()
            if auth {
                sectionExpiredClass.ClearData(controller: self)
            }
            else {
                switch response.result {
                case .success(let jsonResponse):
                    if jsonResponse.responseType.isSuccess {
                        print("post_dashBoardHome_homeTabService:" + "\(jsonResponse.response)");
                        let main = jsonResponse.response.dictionaryValue
                        let ExpiringVehList = main["ExpiringVehList"]?.arrayValue
                        ExpiringVehList!.forEach({ (obj) in
                            self.exevehlistarr.append(ExpiringVehListModelClass.init(data: obj))
                           // self.searchCustomerListArray = self.customerlistarr
                        })
                        self.totalexpiringvehlistTableView.reloadData()
                        if ExpiringVehList?.count == 0 {
                            self.nextpageurl = 0
                        }else{
                            self.nextpageurl += 1
                        }
                       
                    } else {
                        if let code = response.response?.statusCode {
                            if code == 401 || code == 403{
                                sectionExpiredClass.ClearData(controller: self)
                            }
                        }
                        print("post_dashBoardHome_homeTabService :" + "\(jsonResponse)")
//                      self.view.ShowBlackTostWithText(message: jsonResponse.responseMessage, Interval: 2)
                        self.view.ShowBlackTostWithText(message: jsonResponse.response["message"].stringValue, Interval: 3)
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    //                    Message.SomethingWrongAlert(self)
                    if let code = response.response?.statusCode {
                        if code == 401 {
                        }
                    }
                    break
                }
            }
        }
    }
    

}

extension expiringvehiclelistPageVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        
            return exevehlistarr.count
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "listofexpiringvehicletablecell", for: indexPath) as! listofexpiringvehicletablecell
        cell.vehiclenumberLabel.text = exevehlistarr[indexPath.row].vehicle_no + "," 
        cell.fueltyprLabel.text = exevehlistarr[indexPath.row].fuel_type
        cell.carmodelmfgfuelLabel.text = exevehlistarr[indexPath.row].vehicle_make + " " + "-" + " " + exevehlistarr[indexPath.row].vehicle_model
        cell.mfgLabel.text = exevehlistarr[indexPath.row].manufacturing_year
        cell.transmissionLabel.text = exevehlistarr[indexPath.row].transmission_type
        
        if self.exevehlistarr[indexPath.row].inspection_status == "Approved" || self.exevehlistarr[indexPath.row].inspection_status == "approved" {
            cell.inspectionstatusLabel.text = exevehlistarr[indexPath.row].inspection_status
            cell.inspectionstatusLabel.textColor = UIColor.init(hexString: "4BAE4F")
        }else if self.exevehlistarr[indexPath.row].inspection_status == "rejected" {
            cell.inspectionstatusLabel.text = exevehlistarr[indexPath.row].inspection_status
            cell.inspectionstatusLabel.textColor = UIColor.init(hexString: "F44336")
        }else if self.exevehlistarr[indexPath.row].inspection_status == "reinspect" ||
                    self.exevehlistarr[indexPath.row].inspection_status == "reinspection" {
            cell.inspectionstatusLabel.text = "Reinspect"
            cell.inspectionstatusLabel.textColor = UIColor.init(hexString: "F68B33")
        }else if self.exevehlistarr[indexPath.row].inspection_status == "Repair Requested" {
            cell.inspectionstatusLabel.text = exevehlistarr[indexPath.row].inspection_status
            cell.inspectionstatusLabel.textColor = UIColor.init(hexString: "800080")
        }else if self.exevehlistarr[indexPath.row].inspection_status == "" {
            cell.inspectionstatusLabel.text = "In Review"
            cell.inspectionstatusLabel.textColor = UIColor.init(hexString: "0619c3")
        }else{
            cell.inspectionstatusLabel.text = exevehlistarr[indexPath.row].inspection_status
            cell.inspectionstatusLabel.textColor = UIColor.init(hexString: "0619c3")
        }
        if self.exevehlistarr[indexPath.row].brand_icon == "" {
            cell.carbandImageView.image = #imageLiteral(resourceName: "icons8-people-in-car-40")
        }else{
            cell.carbandImageView.pin_updateWithProgress = true
            let aString = self.exevehlistarr[indexPath.row].brand_icon
            let newString = aString!.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
            cell.carbandImageView.pin_setImage(from: URL(string: newString)!, placeholderImage: #imageLiteral(resourceName: "icons8-people-in-car-40"))
        }
        if self.exevehlistarr[indexPath.row].expiry_date == "" || self.exevehlistarr[indexPath.row].expiry_date == nil {
            cell.exepiresdaysLabel.text = "--No Date--"
        }else{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
      //  dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let date = dateFormatter.date(from: self.exevehlistarr[indexPath.row].expiry_date)
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateStr = dateFormatter.string(from:date!)
        cell.exepiresdaysLabel.text = dateStr
        }
        
        let tokms = self.exevehlistarr[indexPath.row].odometer ?? 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let tokmsFormatted = numberFormatter.string(from: NSNumber(value: tokms))
        cell.kmsLabel.text = tokmsFormatted! + "kms"
        cell.htOfexpiresView.constant = 200
            
        return cell
        }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {



            if exevehlistarr.count == 0 ||  exevehlistarr.count < 10 {

            } else {
                if nextpageurl == 0 {

                } else {
                    if indexPath.row >= exevehlistarr.count - 1 {
                        nextpageexpirevehlistServiceCall()
                    }
                }
            }
        }
        
}

class listofexpiringvehicletablecell : UITableViewCell {
    @IBOutlet weak var carbandImageView: UIImageView!
    @IBOutlet weak var vehiclenumberLabel: UILabel!
    @IBOutlet weak var carmodelmfgfuelLabel: UILabel!
    @IBOutlet weak var kmsLabel: UILabel!
    @IBOutlet weak var transmissionLabel: UILabel!
    @IBOutlet weak var exepiresdaysLabel: UILabel!
    @IBOutlet weak var inspectionstatusLabel: UILabel!
    @IBOutlet weak var fueltyprLabel: UILabel!
    @IBOutlet weak var htOfexpiresView: NSLayoutConstraint!
    @IBOutlet weak var mfgLabel: UILabel!
    
}
