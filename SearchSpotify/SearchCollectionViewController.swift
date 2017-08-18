//
//  SearchCollectionViewController.swift
//  SearchSpotify
//
//  Created by Himanshi Bhardwaj on 8/17/17.
//  Copyright © 2017 Himanshi Bhardwaj. All rights reserved.
//

import UIKit

class SearchCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var loadMoreResults: UIButton!
    
    //--------------------------------------
    // MARK: UI elements created programmatically
    //--------------------------------------
    
    let searchController = UISearchController(searchResultsController: nil)
    var signOutButton: UIBarButtonItem?
    
    
    //--------------------------------------
    // MARK: variables
    //--------------------------------------
    
    var searchText = ""
    var tracks: [Track] = []
    var noResultFoundText = "No results found for that search :(\nTry again"
    var searchInstructionText = "Welcome, search for music tracks here"
    let cellsPerRow = 3 //number of per column
    let marginBetweenCellColumns: CGFloat = 2
    let marginBetweenCellLines: CGFloat = 10
    
    
    //--------------------------------------
    // MARK: Functions
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchController()
        setupSignOutButton()
        
        self.loadMoreResults.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.isHidden = tracks.isEmpty
        instructionLabel.isHidden = false
        instructionLabel.text = searchInstructionText
    }
    
    //MARK: init setup functions
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = marginBetweenCellColumns
        flowLayout.minimumLineSpacing = marginBetweenCellLines
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    func setupSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Setting keyboardAppearance dark
        searchController.searchBar.keyboardAppearance = .dark
        
        // Making the search bar translucent
        searchController.searchBar.isTranslucent = true
        //searchController.searchBar.alpha = 1
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = .clear
        
        // Finally add to the searchBarContainerView
        searchBarContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.sizeToFit()
    }
    
    func setupSignOutButton() {
        signOutButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(signOutAction))
        signOutButton?.title = "Sign out"
        //adding button to navigationItem
        self.navigationItem.leftBarButtonItem = signOutButton
    }
    
    //MARK: Collection view controller Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let searchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchResultCollectionViewCell
        searchCell.track = tracks[indexPath.row]
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = .themeColor
        searchCell.selectedBackgroundView = backgroundColorView
        
        return searchCell
    }
    
    //function to set number of columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: Scroll bar Method
    //to hide or show loadMoreResults button end of collection view is reached
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            //reach bottom
            self.loadMoreResults.isHidden = tracks.isEmpty
        }
        else {
            self.loadMoreResults.isHidden = true
        }
    }
    
    
    // MARK: Search bar Methods
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText.isEmpty {
            self.collectionView.isHidden = true
            instructionLabel.isHidden = false
            instructionLabel.text = searchInstructionText
            loadMoreResults.isHidden = true
        }
        else {
            self.collectionView.isHidden = false
            self.searchText = searchText
            //fetch data from Spotify
            SpotifySearchApi.current?.searchTracks(query: searchText, user: User.current, callback: { (tracks) in
                self.tracks = tracks
                //to hide or show instructionLabel based on tracks fetched
                self.instructionLabel.isHidden = !tracks.isEmpty
                self.instructionLabel.text = self.noResultFoundText
                //self.loadMoreResults.isHidden = tracks.isEmpty
                
                self.collectionView.reloadData()
            })
        }
    }
    
    // MARK: Sign out Method
    func signOutAction() {
        //Adding sign out alert
        let signOutAlert = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        
        signOutAlert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { (action: UIAlertAction!) in
            SpotifySearchApi.current?.signOutTheUser()
            
            //go back to login page
            self.self.dismiss(animated: true, completion: nil
            )}))
        
        signOutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            //do nothing
        }))
        
        present(signOutAlert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //Limit number of tracks to 21 and reload collectionView
        tracks = Array(tracks.prefix(21))
        self.collectionView.reloadData()
    }
    
    //--------------------------------------
    // MARK: Action functions
    //--------------------------------------
    
    @IBAction func onTapView(_ sender: Any) {
        searchController.searchBar.endEditing(true)
    }
    
    // Load more tracks Method
    @IBAction func loadMoreResultsButtonTapped(_ sender: UIButton) {
        //fetch more data from Spotify
        SpotifySearchApi.current?.searchMoreTracks(query: searchText, user: User.current, offset: tracks.count, callback: { (tracks) in
            self.tracks += tracks
            self.collectionView.reloadData()
        })
        loadMoreResults.isHidden = true
    }
   
}


//--------------------------------------
// MARK: Extensions
//--------------------------------------

extension SearchCollectionViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

