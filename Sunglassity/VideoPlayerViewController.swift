//
//  VideoPlayerViewController.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2018/02/17.
//  Copyright © 2018年 HideakiTouhara. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

// MARK:- レイヤーをAVPlayerLayerにする為のラッパークラス.

class AVPlayerView: UIView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}


class VideoPlayerViewController: AVPlayerViewController, AVAssetResourceLoaderDelegate {

    var movieData: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let asset = AVURLAsset.init(url: NSURL.init(string: "") as! URL)
        
        let resourceLoader = asset.resourceLoader
        resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        
        let playerItem = AVPlayerItem.init(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        // Viewを生成.
        let videoPlayerView = AVPlayerView(frame:  self.view.bounds)
        
        // UIViewのレイヤーをAVPlayerLayerにする.
        let layer = videoPlayerView.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.player = self.player
        
        // レイヤーを追加する.
        self.view.layer.addSublayer(layer)
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
