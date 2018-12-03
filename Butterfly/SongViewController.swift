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
        if tableView == searchResultsView{
            return songs.count
        }
        else{
            return databaseSongs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchResultsView{
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            let subview = UILabel(frame: CGRect(x: cell.frame.minX, y: cell.frame.minY, width: 300, height: cell.frame.height))
            subview.text = songs[indexPath.item]+" - "+artists[indexPath.item]
            subview.numberOfLines = 0
            cell.addSubview(subview)
            let buttonView = CGRect(x: cell.frame.maxX, y: cell.frame.minY, width: cell.frame.height, height: cell.frame.height)
            let button = UIButton(frame: buttonView)
            button.setTitle("add", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(addToPlaylist), for: .touchUpInside)
            cell.addSubview(button)
            return cell
        }
        else{
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel!.text = databaseSongs[indexPath.item]
            cell.textLabel!.numberOfLines = 0
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    var songs:[String] = []
    var artists:[String] = []
    var searchQuery:String? = nil
    var lastSearch:String? = nil
    var eventId:String! = ""
    var selectedSong:String! = ""
    var databaseSongs:[String] = []
    @IBOutlet weak var searchResultsView: UITableView!
    @IBOutlet weak var playlistView: UITableView!
    
    @objc func addToPlaylist(_ sender: UIButton){
        //finding selected button from https://forums.developer.apple.com/thread/67265
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = searchResultsView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        let selectedSong = songs[indexPath.row] + " - " + artists[indexPath.row]
        var ref: DatabaseReference!
        ref = Database.database().reference()
        //Code to update child values taken from firebase docs on https://firebase.google.com/docs/database/ios/read-and-write
        let childUpdates:[String: AnyObject] = ["/events/\(eventId!)/song-list/\(selectedSong)": "true" as NSString]
        ref.updateChildValues(childUpdates){
            //End of Citation
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/
                let alertController = UIAlertController(title: "Success!", message: "Song Added Successfully", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                //End of Citation
                self.getPlaylist()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsView.dataSource = self
        searchResultsView.delegate = self
        playlistView.dataSource = self
        playlistView.delegate = self
        getPlaylist()
        // Do any additional setup after loading the view.
    }
    
    func getPlaylist() {
        databaseSongs = []
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("events").child(eventId).child("song-list").observeSingleEvent(of: .value, with: {
            snapshot in
            if let someData = snapshot.value as? Dictionary<String, String>{
                for (key, _) in someData{
                    self.databaseSongs.append(key)
                }
                self.playlistView.reloadData()
            }
        })
        
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
