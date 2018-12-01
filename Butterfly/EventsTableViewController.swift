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
        loadInitialData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    func loadInitialData() {
        // 1
        guard let fileName = Bundle.main.path(forResource: "PublicArt", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            // 2
            let json = try? JSONSerialization.jsonObject(with: data),
            // 3
            let dictionary = json as? [String: Any],
            // 4
            let events = dictionary["data"] as? [[Any]]
            else { return }
        // 5
//        let validEvents = events.compactMap { Event(json: $0) }
//        eventsArray.append(contentsOf: validEvents)
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
