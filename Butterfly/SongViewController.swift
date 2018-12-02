//
//  SongViewController.swift
//  Butterfly
//
//  Created by Julia Dickerman on 12/1/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit

class SongViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        cell.textLabel!.text = songData[indexPath.item].name
        return cell
    }
    

    
    @IBOutlet weak var searchBar: UISearchBar!
    var songData:[Song] = []
    var searchQuery:String? = nil
    var lastSearch:String? = nil
    var searchResults:APIResults? = nil
    @IBOutlet weak var searchResultsView: UITableView!
    
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
                self.searchResults = try? JSONDecoder().decode(APIResults.self, from: data)
            }
            if let tempSongs = self.searchResults?.track{
                self.songData = tempSongs
            }
            DispatchQueue.main.async {
                self.searchResultsView.reloadData()
            }
        }
        print(searchResults)
        print(songData)
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
