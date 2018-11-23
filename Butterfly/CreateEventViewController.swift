//
//  CreateEventViewController.swift
//  
//
//  Created by Jennifer Stevens on 11/23/18.
//

import UIKit
import FirebaseDatabase

class CreateEventViewController: UIViewController {

    @IBOutlet var eventTitle: UITextField!
    @IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var eventLat: UITextField!
    @IBOutlet var eventLong: UITextField!
    @IBOutlet var eventOpen: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createEvent(_ sender: Any) {
        var eventName:NSString
        var eventDate:NSString
        var eventLongitude:NSNumber
        var eventLatitude:NSNumber
        var isOpen:NSString
        
        let title = eventTitle.text
        if title != ""{
            print("valid")
            eventName = String(title!) as NSString
        }
        else{
            print("invalid")
        }
        var date = eventDatePicker.date
        date.addTimeInterval(-6*60*60)
        print(date)
        eventDate = date.description as NSString

        let lat = eventLat.text
        if let latitude = Double(lat!){
            eventLatitude = latitude as NSNumber
        }
        else{
            print("invalid")
        }
        let long = eventLong.text
        if let longitude = Double(long!){
            eventLongitude = longitude as NSNumber
        }
        else{
            print("invalid")
        }
        
        
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
