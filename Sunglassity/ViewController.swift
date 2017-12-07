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
    @IBOutlet weak var configView: UIView!
    @IBOutlet weak var configViewHeight: NSLayoutConstraint!
    
    let configuration = ARWorldTrackingConfiguration()
    var url: URL!
    
    // ARVideoKit
    var recorder:RecordAR?
    
    enum Mode {
        case normal
        case draw
        case photo
    }
    
    var mode: Mode = .normal
    
    enum Thickness: String {
        case thick
        case medium
        case thin
        
        static let allValues: [Thickness] = [.thick, .medium, .thin]
        
        var thickness: CGFloat {
            switch self {
            case .thick:
                return 0.005
            case .medium:
                return 0.003
            case .thin:
                return 0.001
            }
        }
    }
    
    var thickness: Thickness = .medium
    
    enum Color: String {
        case red
        case blue
        case white
        
        static let allValues: [Color] = [.red, .blue, .white]
        
        var color: UIColor {
            switch self {
            case .red:
                return UIColor.red
            case .blue:
                return UIColor.blue
            case .white:
                return UIColor.white
            }
        }
    }
    
    var color: Color = .white
    
    // pictureのモード
    enum PhotoMode {
        case trace
        case put
    }
    
    var photoMode: PhotoMode = .trace
    
    // cell関連
    var previousThicknessNumber = IndexPath(row: 1, section: 0)
    var previousColorNumber = IndexPath(row: 1, section: 1)
    
    var pictureBoard: SCNNode!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARKitの準備
        self.sceneView.session.run(configuration)
        
        // ARVideoKit
        recorder = RecordAR(ARSceneKit: sceneView)
        recorder?.prepare(configuration)
        recorder?.deleteCacheWhenExported = false
        
        // ARSCNViewDelegate
        self.sceneView.delegate = self
        
        // UI設定
        self.configViewHeight.constant = 0
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
            let text = "AR動画だよ！"
            let items = [text, url] as [Any]
            let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(activityVc, animated: true, completion: nil)
        })
    }
    
    @IBAction func draw(_ sender: UIPanGestureRecognizer) {
        if mode != .draw { return }
        let point = sender.location(in: sceneView)
        let pointVec3 = SCNVector3Make(Float(point.x), Float(point.y), 0.99)
        let sphereNode = SCNNode(geometry: SCNSphere(radius: thickness.thickness))
        sphereNode.position = sceneView.unprojectPoint(pointVec3)
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = color.color
    }
    
    @IBAction func setDrawing(_ sender: UIButton) {
        configViewHeight.constant = 246
        mode = .draw
    }
    
    @IBAction func check(_ sender: UIButton) {
        if mode == .photo {
            if photoMode == .trace {
                photoMode = .put
            }
        }
    }
    
    @IBAction func determine(_ sender: UIButton) {
        configViewHeight.constant = 0
    }
    
    @IBAction func selectPicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if mode != .photo { return }
        if photoMode == .trace {
            guard let pointOfView = sceneView.pointOfView else { return }
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let currentPositionOfCamera = orientation + location
            pictureBoard.position = currentPositionOfCamera
            pictureBoard.eulerAngles = pointOfView.eulerAngles
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OptionCell
        if indexPath.section == 0 {
            cell.name.text = Thickness.allValues[indexPath.row].rawValue
        } else if indexPath.section == 1 {
            cell.name.text = Color.allValues[indexPath.row].rawValue
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = collectionView.cellForItem(at: previousThicknessNumber)
            cell?.backgroundColor = UIColor.white
            thickness = Thickness.allValues[indexPath.row]
            previousThicknessNumber.row = indexPath.row
        } else if indexPath.section == 1 {
            let cell = collectionView.cellForItem(at: previousColorNumber)
            cell?.backgroundColor = UIColor.white
            color = Color.allValues[indexPath.row]
            previousColorNumber.row = indexPath.row
        }
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pictureBoard = SCNNode(geometry: SCNPlane(width: 0.3, height: 0.3))
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        pictureBoard.geometry?.firstMaterial?.diffuse.contents = image
        self.sceneView.scene.rootNode.addChildNode(pictureBoard)
        mode = .photo
        self.dismiss(animated: true, completion: nil)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
