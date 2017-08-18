//
//  SignInViewController.swift
//  SearchSpotify
//
//  Created by Himanshi Bhardwaj on 8/17/17.
//  Copyright © 2017 Himanshi Bhardwaj. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signInButton: SPTConnectButton!
    
    
    //--------------------------------------
    // MARK: variables
    //--------------------------------------
    
    let searchApi = SpotifySearchApi()
    
    
    //--------------------------------------
    // MARK: Functions
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = "Search for your favorite tracks \non spotify"
        SpotifySearchApi.current = searchApi
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTapped(_ sender: SPTConnectButton) {
        searchApi.loginURL!.open()
        if searchApi.auth.canHandle(searchApi.auth.redirectURL) {
                NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: Notification.Name("signInSuccessful"), object: nil)
        }
        
    }
    
    func updateAfterFirstLogin() {
        performSegue(withIdentifier: "signInSegue", sender: self)
    }
}


//--------------------------------------
// MARK: Extensions
//--------------------------------------

extension URL {
    func open() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(self)
        } else {
            UIApplication.shared.openURL(self)
        }
    }
}
