//
//  SongViewController.swift
//  Butterfly
//
//  Created by Julia Dickerman on 12/1/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SongViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = songs[indexPath.item]+" - "+artists[indexPath.item]
        let buttonView = CGRect(x: cell.frame.maxX, y: cell.frame.minY, width: cell.frame.height, height: cell.frame.height)
        let button = UIButton(frame: buttonView)
        button.setTitle("add", for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(addToPlaylist), for: .touchUpInside)
        cell.addSubview(button)
        return cell
    }
    

    
    @IBOutlet weak var searchBar: UISearchBar!
    var songs:[String] = []
    var artists:[String] = []
    var searchQuery:String? = nil
    var lastSearch:String? = nil
    var eventId:String! = ""
    @IBOutlet weak var searchResultsView: UITableView!
    
    @objc func addToPlaylist(){
        let user = Auth.auth().currentUser
        if let eventCreator = user{
            let uid = eventCreator.uid
            let creator = eventCreator.displayName! as NSString
            var ref: DatabaseReference!
            ref = Database.database().reference()
            print(creator)
            let eventDetails:[String : AnyObject] = ["Title": eventName, "Date": eventDate, "Creator": creator, "CreatorId": uid as AnyObject, "Latitude": eventLatitude, "Longitude": eventLongitude, "Open": "false" as NSString]
            let detailedVC = EventInviteViewController()
            detailedVC.event = eventDetails
            navigationController?.pushViewController(detailedVC, animated: true)
        }
        else{
            //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/
            
            let alertController = UIAlertController(title: "ERROR", message: "Must be logged in to create event", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            //End of Citation
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsView.dataSource = self
        searchResultsView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var searchText = searchBar.text
        searchText = searchText?.replacingOccurrences(of: " ", with: "+")
        //sanitizing string code taken from piazza shoutout @MasonJHall
        var badCharacters = CharacterSet.init(charactersIn: "\'")
        badCharacters.insert(charactersIn: "‘’")

        let cleanedString = searchText?.components(separatedBy: badCharacters).joined()
        searchQuery = cleanedString
        searchResultsView.reloadData()
        if(searchQuery == lastSearch){
            searchResultsView.reloadData()
        }else{
            lastSearch = searchQuery
            fetchSearchData()
        }
    }
    
    func fetchSearchData(){
        let backgroundQueue = DispatchQueue(label: "queue", qos: .background)
        backgroundQueue.async {
            let url = URL(string: "http://ws.audioscrobbler.com/2.0/?method=track.search&track=\(self.searchQuery!)&api_key=2af21301da406b8372c5677f623750f0&format=json")
            if let data = try? Data(contentsOf: url!){
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let results = json!["results"] as? [String: Any]{
                        if let trackmatches = results["trackmatches"] as? [String: Any]{
                            if let track = trackmatches["track"] as? [Any]{
                                self.songs = []
                                self.artists = []
                                for item in track {
                                    if let song = item as? [String: Any]{
                                        if let title = song["name"] as? String {
                                            print(title)
                                            self.songs.append(title)
                                        }
                                        if let artist = song["artist"] as? String {
                                            print(artist)
                                            self.artists.append(artist)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.searchResultsView.reloadData()
            }
        }

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
