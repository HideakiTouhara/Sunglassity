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

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    let fileOutput = AVCaptureMovieFileOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Session, Deviceの準備
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        captureSession.addOutput(fileOutput)
        
        // Preview画面
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        self.view.bringSubview(toFront: recordButton)
        self.view.bringSubview(toFront: stopButton)
        
        // セッション開始
        captureSession.startRunning()
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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let filePath = "\(documentDirectory)/temp.mp4"
        let fileURL = URL(fileURLWithPath: filePath)
        fileOutput.startRecording(to: fileURL, recordingDelegate: self)
    }
    
    @IBAction func tappedStopButton(_ sender: UIButton) {
        fileOutput.stopRecording()
    }
    
    


}

