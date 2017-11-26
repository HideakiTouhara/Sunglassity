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

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    let fileOutput = AVCaptureMovieFileOutput()
    
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARKitの準備
        self.sceneView.session.run(configuration)
        
        // Session, Deviceの準備
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        captureSession.addOutput(fileOutput)
        
        self.view.bringSubview(toFront: recordButton)
        self.view.bringSubview(toFront: stopButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let assetLib = ALAssetsLibrary()
        assetLib.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL, completionBlock: nil)
    }
    
    @IBAction func tappedRecordButton(_ sender: UIButton) {
        // セッション開始
        captureSession.startRunning()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = "\(documentDirectory)/temp.mp4"
        let fileURL = URL(fileURLWithPath: filePath)
        fileOutput.startRecording(to: fileURL, recordingDelegate: self)
    }
    
    @IBAction func tappedStopButton(_ sender: UIButton) {
        fileOutput.stopRecording()
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

