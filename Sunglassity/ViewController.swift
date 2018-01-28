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
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var configView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var configViewHeight: NSLayoutConstraint!
    @IBOutlet weak var configViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var determineView: UIView!
    @IBOutlet weak var determineButton: UIButton!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    let configuration = ARWorldTrackingConfiguration()
    var url: URL!
    
    // ARVideoKit
    var recorder:RecordAR?
    
    enum Mode {
        case normal
        case draw
        case photo
        case photoTrace
        case text
        case textTrace
        case isRecord
    }
    
    var mode: Mode = .normal {
        didSet {
            switch mode {
            case .normal:
                makeButtonAppear()
                checkButton.isHidden = true
            case .draw:
                recordButton.isHidden = true
                collectionView.reloadData()
            case .photo:
                makeButtonHidden()
            case .text:
                makeButtonHidden()
                inputTextField.isHidden = false
                collectionView.reloadData()
            case .photoTrace:
                makeButtonHidden()
                inputTextField.isHidden = true
                checkButton.isHidden = false
            case .textTrace:
                makeButtonHidden()
                checkButton.isHidden = false
            case .isRecord:
                makeButtonHidden()
                // recordButtonだけ表示状態に戻す
                recordButton.isHidden = false
            }
        }
    }
    
    var drawSize: Size = Size.defaultValue
    var drawColor: Color = Color.defaultValue
    var textSize: Size = Size.defaultValue
    var textColor: Color = Color.defaultValue
    
    // cell関連
    var previousDrawSizeNumber = IndexPath(row: Size.defaultValue.hashValue, section: 0)
    var previousDrawColorNumber = IndexPath(row: Color.defaultValue.hashValue, section: 1)
    var previousTextSizeNumber = IndexPath(row: Size.defaultValue.hashValue, section: 0)
    var previousTextColorNumber = IndexPath(row: Color.defaultValue.hashValue, section: 1)
    
    var pictureBoard: SCNNode!
    var textNode: SCNNode!
    
    var textViewController: TextViewController?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARKitの準備
        self.sceneView.session.run(configuration)
        
        // ARVideoKit
        recorder = RecordAR(ARSceneKit: sceneView)
        recorder?.prepare(configuration)
        recorder?.deleteCacheWhenExported = false
        
        // Delegate
        self.sceneView.delegate = self
        self.inputTextField.delegate = self
        
        // UI設定
        self.configViewHeight.constant = 0
        configView.backgroundColor = UIColor.clear
        determineView.backgroundColor = UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 0.6)
        collectionView.backgroundColor = UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 0.6)
        
        // キーボードが開くのを受け取る
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                configViewBottom.constant = -keyboard.cgRectValue.size.height
                configViewHeight.constant = 100
                
                determineView.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recorder?.rest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeButtonHidden() {
        recordButton.isHidden = true
        
        drawButton.isHidden = true
        photoButton.isHidden = true
        textButton.isHidden = true
    }
    
    func makeButtonAppear() {
        recordButton.isHidden = false
        
        drawButton.isHidden = false
        photoButton.isHidden = false
        textButton.isHidden = false
    }
    
    func resetCell() {
        previousDrawSizeNumber = IndexPath(row: Size.defaultValue.hashValue, section: 0)
        previousDrawColorNumber = IndexPath(row: Color.defaultValue.hashValue, section: 1)
        previousTextSizeNumber = IndexPath(row: Size.defaultValue.hashValue, section: 0)
        previousTextColorNumber = IndexPath(row: Color.defaultValue.hashValue, section: 1)
        
        drawSize = Size.defaultValue
        drawColor = Color.defaultValue
        textSize = Size.defaultValue
        textColor = Color.defaultValue
    }
    
    // MARK: - IBAction
    @IBAction func tappedRecordButton(_ sender: UIButton) {
        if mode == .isRecord {
            recorder?.stopAndExport({ (url, _, _) in
                self.url = url
//                let text = "AR動画だよ！"
//                let items = [text, url] as [Any]
//                let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)
//                self.present(activityVc, animated: true, completion: nil)
                let databaseRef = Database.database().reference(fromURL: "https://sunglassity.firebaseio.com/")
                let videoData = try? NSData(contentsOf: url, options: .mappedIfSafe)
                let base64String = videoData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as! String
                let user: NSDictionary = ["username": "a", "video": base64String]
                databaseRef.child("Posts").childByAutoId().setValue(user)
            })
            mode = .normal
            recordButton.setTitle("●", for: .normal)
            recordButton.setTitleColor(UIColor.red, for: .normal)
        } else {
            recorder?.record()
            mode = .isRecord
            recordButton.setTitle("■", for: .normal)
            recordButton.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    @IBAction func draw(_ sender: UIPanGestureRecognizer) {
        if mode != .draw { return }
        let point = sender.location(in: sceneView)
        let pointVec3 = SCNVector3Make(Float(point.x), Float(point.y), 0.99)
        let sphereNode = SCNNode(geometry: SCNSphere(radius: drawSize.thickness))
        sphereNode.position = sceneView.unprojectPoint(pointVec3)
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = drawColor.color
    }
    
    @IBAction func setDrawing(_ sender: UIButton) {
        configViewHeight.constant = 100
        configViewBottom.constant = 0
        determineView.isHidden = false
        mode = .draw
    }
    
    @IBAction func check(_ sender: UIButton) {
        if mode == .photoTrace {
            mode = .normal
        } else if mode == .textTrace {
            mode = .normal
        }
    }
    
    @IBAction func determine(_ sender: UIButton) {
        configViewHeight.constant = 0
        determineView.isHidden = true
    }
    
    @IBAction func selectPicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func inputText(_ sender: UIButton) {
        mode = .text
//        let viewController = TextViewController()
//        viewController.embed(in: self)
//        self.textViewController = viewController
    }
    
    
    
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if mode == .photoTrace {
            guard let pointOfView = sceneView.pointOfView else { return }
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let currentPositionOfCamera = orientation + location
            pictureBoard.position = currentPositionOfCamera
            pictureBoard.eulerAngles = pointOfView.eulerAngles
        } else if mode == .textTrace {
            guard let pointOfView = sceneView.pointOfView else { return }
            let transform = pointOfView.transform
            let orientationX = SCNVector3(-transform.m11, -transform.m12, -transform.m13)
            let orientationZ = SCNVector3(-transform.m31 * 1.2, -transform.m32 * 1.2, -transform.m33 * 1.2)
            let location = SCNVector3(transform.m41, transform.m42 - 1, transform.m43)
            let currentPositionOfCamera = orientationX + orientationZ + location
            textNode.position = SCNVector3(currentPositionOfCamera.x, currentPositionOfCamera.y, currentPositionOfCamera.z)
            textNode.eulerAngles = pointOfView.eulerAngles
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
            cell.name.text = Size.allValues[indexPath.row].rawValue
            if indexPath.row == Size.defaultValue.hashValue {
                cell.checkLabel.isHidden = false
            } else {
                cell.checkLabel.isHidden = true
            }
        } else if indexPath.section == 1 {
            cell.name.text = Color.allValues[indexPath.row].rawValue
            if indexPath.row == Color.defaultValue.hashValue {
                cell.checkLabel.isHidden = false
            } else {
                cell.checkLabel.isHidden = true
            }
        }
        resetCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if mode == .draw {
                let cell = collectionView.cellForItem(at: previousDrawSizeNumber) as! OptionCell
                cell.checkLabel.isHidden = true
                drawSize = Size.allValues[indexPath.row]
                previousDrawSizeNumber.row = indexPath.row

            } else if mode == .text {
                let cell = collectionView.cellForItem(at: previousTextSizeNumber) as! OptionCell
                cell.checkLabel.isHidden = true
                textSize = Size.allValues[indexPath.row]
                previousTextSizeNumber.row = indexPath.row
            }
        } else if indexPath.section == 1 {
            if mode == .draw {
                let cell = collectionView.cellForItem(at: previousDrawColorNumber) as! OptionCell
                cell.checkLabel.isHidden = true
                drawColor = Color.allValues[indexPath.row]
                previousDrawColorNumber.row = indexPath.row
            } else if mode == .text {
                let cell = collectionView.cellForItem(at: previousTextColorNumber) as! OptionCell
                cell.checkLabel.isHidden = true
                textColor = Color.allValues[indexPath.row]
                previousTextColorNumber.row = indexPath.row

            }
        }
        let cell = collectionView.cellForItem(at: indexPath) as! OptionCell
        cell.checkLabel.isHidden = false
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pictureBoard = SCNNode(geometry: SCNPlane(width: 0.45, height: 0.6))
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        pictureBoard.geometry?.firstMaterial?.diffuse.contents = image
        self.sceneView.scene.rootNode.addChildNode(pictureBoard)
        mode = .photoTrace
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        inputTextField.isHidden = true
        configViewBottom.constant = 0
        configViewHeight.constant = 0
        determineButton.isHidden = false
        
        let text = SCNText(string: inputTextField.text, extrusionDepth: 0.05)
        text.font = UIFont(name: "HiraKakuProN-W6", size: textSize.fontSize)
        textNode = SCNNode(geometry: text)
        textNode.geometry?.firstMaterial?.diffuse.contents = textColor.color
        self.sceneView.scene.rootNode.addChildNode(textNode)
        mode = .textTrace
        return true
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
