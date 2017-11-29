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
        let results = sceneView.hitTest(point, types: .featurePoint)
        if let hitPoint = results.first {
            let length = sqrt(hitPoint.worldTransform.columns.3.x * hitPoint.worldTransform.columns.3.x + hitPoint.worldTransform.columns.3.y * hitPoint.worldTransform.columns.3.y + hitPoint.worldTransform.columns.3.z * hitPoint.worldTransform.columns.3.z)
            let point = SCNVector3(hitPoint.worldTransform.columns.3.x / length, hitPoint.worldTransform.columns.3.y / length, hitPoint.worldTransform.columns.3.z / length)
            let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
            sphereNode.position = point
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        }
    }
    
    
    


}

