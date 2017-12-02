//
//  ViewController.swift
//  Sunglassity
//
//  Created by HideakiTouhara on 2017/11/19.
//  Copyright © 2017年 HideakiTouhara. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import ARKit
import ARVideoKit

class ViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var url: URL!
    
    // ARVideoKit
    var recorder:RecordAR?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARKitの準備
        self.sceneView.session.run(configuration)
        
        // ARVideoKit
        recorder = RecordAR(ARSceneKit: sceneView)
        recorder?.prepare(configuration)
        recorder?.deleteCacheWhenExported = false
        
        // ボタンを前面に
        self.view.bringSubview(toFront: recordButton)
        self.view.bringSubview(toFront: stopButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recorder?.rest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func tappedRecordButton(_ sender: UIButton) {
        recorder?.record()
    }
    
    @IBAction func tappedStopButton(_ sender: UIButton) {
        recorder?.stopAndExport({ (url, _, _) in
            self.url = url
            let text = "シェア"
            let items = [text, url] as [Any]
            let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(activityVc, animated: true, completion: nil)
        })
    }
    
    @IBAction func draw(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: sceneView)
        let pointVec3 = SCNVector3Make(Float(point.x), Float(point.y), 0.99)
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphereNode.position = sceneView.unprojectPoint(pointVec3)
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
    }
}
