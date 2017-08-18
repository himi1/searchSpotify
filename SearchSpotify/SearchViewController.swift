//
//  SearchViewController.swift
//  SearchSpotify
//
//  Created by Himanshi Bhardwaj on 8/17/17.
//  Copyright © 2017 Himanshi Bhardwaj. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchText = ""
    var tracks: [Track] = []
    
    override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    tableView.isHidden = true
    
    // Set up instructions
    let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
    textFieldInsideSearchBar?.textColor = UIColor.white
    searchBar.keyboardAppearance = .dark
    
    self.navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
    self.tableView.isHidden = tracks.isEmpty
    
    self.navigationController?.isNavigationBarHidden = true
    
    if !searchText.characters.isEmpty {
    
    SpotifySearchApi.current?.searchTracks(query: searchText, user: User.current, callback: { (tracks) in
    self.tracks = tracks
    self.tableView.reloadData()
    })
    }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return tracks.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = UITableViewCell()
    let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
    searchCell.track = tracks[indexPath.row]
    searchCell.selectionStyle = .default
    cell = searchCell as SearchResultCell
    
    let backgroundColorView = UIView()
    backgroundColorView.backgroundColor = UIColor(red: 0.20, green: 0.07, blue: 0.31, alpha: 1.0)
    cell.selectedBackgroundView = backgroundColorView
    return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    /*if segmentedControl.selectedSegmentIndex == 0 {
     if !addedtoQueue[indexPath.row] {
     // reload tableview
     addedtoQueue[indexPath.row] = true
     tableView.reloadData()
     
     // get the track
     let track = tracks[indexPath.row]
     let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
     searchCell.track = track
     
     // add track to playlist
     Queue.current!.addTrack(track, user: User.current!)
     }
     } else {
     */
    tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
    self.tableView.isHidden = true
    
    }
    else {
    self.tableView.isHidden = false
    
    self.searchText = searchText
    
    
    SpotifySearchApi.current?.searchTracks(query: searchText, user: User.current, callback: { (tracks) in
    self.tracks = tracks
    self.tableView.reloadData()
    })
    }
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
    view.endEditing(true)
    //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapView(_ sender: Any) {
    view.endEditing(true)
    }
}
