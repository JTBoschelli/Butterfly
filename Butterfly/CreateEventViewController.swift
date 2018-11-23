//
//  CreateEventViewController.swift
//  
//
//  Created by Jennifer Stevens on 11/23/18.
//

import UIKit

class CreateEventViewController: UIViewController {

    @IBOutlet var eventTitle: UITextField!
    @IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var eventLat: UITextField!
    @IBOutlet var eventLong: UITextField!
    @IBOutlet var eventOpen: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDatePicker.timeZone = NSTimeZone.local
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createEvent(_ sender: Any) {
        let title = eventTitle.text
        let date = eventDatePicker.date
        let lat = eventLat.text
        let long = eventLong.text
        let isOpen = eventOpen.isOn
        print(isOpen)
        print(date)
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
