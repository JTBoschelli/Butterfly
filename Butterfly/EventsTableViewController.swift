//
//  EventsTableViewController.swift
//  Butterfly
//
//  Created by Julia Dickerman on 11/30/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit

class EventsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var eventsArray: [Event] = []
    @IBOutlet weak var eventsTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        cell.textLabel!.text = eventsArray[indexPath.row].title
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        eventsTable.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        eventsTable.dataSource = self
        eventsTable.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: self)
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
