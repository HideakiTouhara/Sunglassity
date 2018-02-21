//
//  TimelineViewController.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2018/01/09.
//  Copyright © 2018年 HideakiTouhara. All rights reserved.
//

import UIKit
import Firebase

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [NSDictionary]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.endRefreshing()
        loadData()
        tableView.estimatedRowHeight = 450
        tableView.rowHeight = 450
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func refresh() {
        loadData()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadData() {
        // Firebaseから取ってくる
        let firebase = Database.database().reference(fromURL: "https://sunglassity.firebaseio.com/").child("Posts")
        firebase.queryLimited(toLast: 10).observe(.value) { (snapshot, error) in
            var tempItems = [NSDictionary]()
            for item in(snapshot.children) {
                let child = item as! DataSnapshot
                let dict = child.value
                tempItems.append(dict as! NSDictionary)
            }
            self.items = tempItems
        }
    }
    
    func showVideo(indexPath: IndexPath) {
        let playerViewController = VideoPlayerViewController()
        let decodeData = (base64encoded:items[indexPath.row]["video"])
        let decodedDate = NSData(base64Encoded: decodeData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        playerViewController.movieData = decodedDate as! Data
        self.present(playerViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadData()
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let decodeProfileImageData = (base64Encoded:items[indexPath.row]["thumbnail"])
        let decodedProfileImageData = NSData(base64Encoded: decodeProfileImageData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedProfileImage = UIImage(data: decodedProfileImageData! as Data)
        
        let decodeThumbnailData = (base64Encoded:items[indexPath.row]["thumbnail"])
        let decodedThumbnailData = NSData(base64Encoded: decodeThumbnailData as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let decodedThumbNail = UIImage(data: decodedThumbnailData! as Data)

        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell") as! TimelineTableViewCell
        cell.username.text = (items[indexPath.row]["username"] as! String)
        cell.profileImage.image = decodedProfileImage
        cell.thumbnail.image = decodedThumbNail
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showVideo(indexPath: indexPath)
    }
}
