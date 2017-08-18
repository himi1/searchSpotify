//
//  SearchResultCollectionViewCell.swift
//  SearchSpotify
//
//  Created by Himanshi Bhardwaj on 8/17/17.
//  Copyright © 2017 Himanshi Bhardwaj. All rights reserved.
//

import UIKit
//import AlamofireImage

class SearchResultCollectionViewCell: UICollectionViewCell {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var nameLabel: MarqueeLabel!
    @IBOutlet weak var artistsLabel: MarqueeLabel!
    @IBOutlet weak var albumImageView: UIImageView!
    
    //--------------------------------------
    // MARK: variables
    //--------------------------------------
    
    var track: Track! {
        didSet {
            nameLabel.text = track.name
            
            // Setting up artist label
            let artists = track.artists
            var artistNames: [String] = []
            for i in 0..<artists.count {
                let name = artists[i]["name"] as! String
                artistNames.append(name)
            }
            artistsLabel.text = artistNames.joined(separator: ", ")
            
            // Setting up the album image
            if !(track.album["images"] as! [[String: Any]]).isEmpty {
                let imageDict = track.album["images"] as! [[String: Any]]
                albumImageView.downloadFrom(link: imageDict[0]["url"] as! String)
            }
        }
    }

}


//--------------------------------------
// MARK: Extensions
//--------------------------------------

extension UIImageView {
    func downloadFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadFrom(url: url, contentMode: mode)
    }
}
