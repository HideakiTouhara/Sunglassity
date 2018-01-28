//
//  TimelineViewController.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2018/01/09.
//  Copyright © 2018年 HideakiTouhara. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TimelineViewController: AVPlayerViewController, AVAssetResourceLoaderDelegate {
    
    var movieData: Data? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let asset = AVURLAsset.init(url: NSURL.init(string: "") as! URL)
        
        let resourceLoader = asset.resourceLoader
        resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        
        let playerItem = AVPlayerItem.init(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        loadingRequest.contentInformationRequest?.contentType = "public.mpeg-4";
        loadingRequest.contentInformationRequest?.contentLength = Int64((self.movieData?.count)!)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        
        let requestedData = self.movieData?.subdata(in: Int(loadingRequest.dataRequest!.requestedOffset) ..< Int(loadingRequest.dataRequest!.requestedLength))
        
        loadingRequest.dataRequest?.respond(with: requestedData!)
        loadingRequest.finishLoading()
        
        return true
    }
    
}
