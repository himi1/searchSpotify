//
//  SpotifySearchApi.swift
//  SearchSpotify
//
//  Parts of this code taken from: https://github.com/katiejiang/kickback/blob/a17191189095a26a77890aa6d7c412a30f5fd46e/Kickback/APIManager.swift
//  Created by Himanshi Bhardwaj on 8/17/17.
//  Copyright © 2017 Himanshi Bhardwaj. All rights reserved.
//


import Foundation
import Alamofire

class SpotifySearchApi {
    typealias JSON = [String: Any]
    var auth: SPTAuth
    var session: SPTSession!
    var loginURL: URL?
    var lastRequest: DataRequest?
    
    private static var _current: SpotifySearchApi?
    
    static var current: SpotifySearchApi? {
        get {
            return _current
        }
        set (manager) {
            _current = manager
            if let manager = manager {
                // store the session data
                if let session = manager.session {
                    let defaults = UserDefaults.standard
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session)
                    defaults.set(sessionData, forKey: "SpotifySession")
                    defaults.synchronize()
                }
            }
        }
    }
    
    init() {
        self.auth = SPTAuth.defaultInstance()!
        self.auth.clientID = SearchSpotifyData.clientID
        self.auth.redirectURL = URL(string: SearchSpotifyData.redirectURIs)
        self.auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope]
        self.auth.sessionUserDefaultsKey = "SpotifySession" // user defaults key to automatically save the session when it changes
        self.loginURL = auth.spotifyWebAuthenticationURL()
    }
    
    //To refresh token
    func refreshToken() {
        auth.renewSession(session) { (error, newSession) in
            if let error = error {
                print("Error refreshing token: \(error.localizedDescription)")
            } else {
                self.session = newSession
            }
        }
    }
    
    //to create a new user
    func createUser() {
        SPTUser.requestCurrentUser(withAccessToken: session.accessToken, callback: { (error: Error?, response: Any?) in
            if let error = error {
                print("Error requesting in createUser(): \(error.localizedDescription)")
            } else {
                let spotifyUser = response as! SPTUser
                var dictionary: [String: Any] = [:]
                dictionary["id"] = spotifyUser.canonicalUserName
                if spotifyUser.displayName == nil {
                    dictionary["name"] = ""
                    
                } else {
                    dictionary["name"] = spotifyUser.displayName
                }
                if spotifyUser.smallestImage != nil {
                    dictionary["profileImageURL"] = spotifyUser.smallestImage.imageURL.absoluteString
                }
                let status = spotifyUser.product
                dictionary["premium"] = status == SPTProduct.premium
                let user = User(dictionary)
                User.current = user
                NotificationCenter.default.post(name: Notification.Name(rawValue: "user.currentSetup"), object: nil)
            }
        })
    }
    
    //to search for new tracks based on a search query
    func searchTracks(query: String, user: User?, callback: @escaping ([Track]) -> Void) -> Void {
        if lastRequest != nil {
            lastRequest!.cancel()
            lastRequest = nil
        }
        var results: [Track] = []
        let urlRequest = try! SPTSearch.createRequestForSearch(withQuery: query, queryType: .queryTypeTrack, accessToken: session.accessToken)
        lastRequest = Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let tracks = readableJSON["tracks"] as? JSON {
                    if let items = tracks["items"] as? [JSON] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var dictionary: [String: Any] = [:]
                            dictionary["id"] = item["id"]
                            dictionary["name"] = item["name"]
                            dictionary["album"] =  item["album"] as! JSON
                            dictionary["artists"] = item["artists"] as! [JSON]
                            dictionary["userId"] = user?.id
                            dictionary["uri"] = item["uri"]
                            dictionary["likes"] = 0
                            dictionary["likedByUsers"] = []
                            dictionary["duration_ms"] = item ["duration_ms"]
                            let track = Track(dictionary)
                            results.append(track)
                        }
                    }
                }
                callback(results)
            } catch {
                print("Error while searching tracks: \(error.localizedDescription)")
            }
        }
    }

    //to search for more tracks based on a search query, with a given offset
    func searchMoreTracks(query: String, user: User?, offset: Int, callback: @escaping ([Track]) -> Void) -> Void {
        if lastRequest != nil {
            lastRequest!.cancel()
            lastRequest = nil
        }
        var results: [Track] = []
        let urlRequest = try! SPTSearch.createRequestForSearch(withQuery: query, queryType: .queryTypeTrack, offset: offset, accessToken: session.accessToken)
        lastRequest = Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let tracks = readableJSON["tracks"] as? JSON {
                    if let items = tracks["items"] as? [JSON] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var dictionary: [String: Any] = [:]
                            dictionary["id"] = item["id"]
                            dictionary["name"] = item["name"]
                            dictionary["album"] =  item["album"] as! JSON
                            dictionary["artists"] = item["artists"] as! [JSON]
                            dictionary["userId"] = user?.id
                            dictionary["uri"] = item["uri"]
                            dictionary["likes"] = 0
                            dictionary["likedByUsers"] = []
                            dictionary["duration_ms"] = item ["duration_ms"]
                            let track = Track(dictionary)
                            results.append(track)
                        }
                    }
                }
                callback(results)
            } catch {
                print("Error while searching tracks: \(error.localizedDescription)")
            }
        }
    }

    //to sign out current user, and set current user nil
    func signOutTheUser() {
        SPTAuth.defaultInstance().session = nil
        
    }
    
}
