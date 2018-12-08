//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 10/2/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import ARKit
import MobileCoreServices
import SceneKit
import UIKit
import VideoToolbox

struct LanguageAPI {
    static var languageKey: String = UserDefaults.standard.string(forKey: "languageKey") ?? "Afrikaans" {
        didSet {
            UserDefaults.standard.set(languageKey, forKey: "languageKey")
        }
    }
    static var languageValue: String = UserDefaults.standard.string(forKey: "languageValue") ?? "af" {
        didSet {
            UserDefaults.standard.set(languageValue, forKey: "languageValue")
        }
    }
    static var indexPath = 0
}

struct SelectedMLModel {
    static var model = "Office"
    static var indexPath = 0
}

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UITextFieldDelegate {
    @IBAction func settingAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var labelerButton: UIButton!
    var alertController: UIAlertController?
    lazy var translator = ROGoogleTranslate()
    lazy var model = ImageModel()
    lazy var storageContoller = StorageController()

    var timer: Timer?

    // Create a session configuration
    var configuration = ARImageTrackingConfiguration()

    private var maxCharactersAllowedForLabel = 20
    private let fileManager = FileManager.default

    var imageAnchors = Set<ARReferenceImage>() {
            didSet{
                self.configuration.trackingImages = imageAnchors
                sceneView.session.run(configuration)
            }
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"

        // Load previous images
        loadImageAnchors()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!

        // Set the scene to the view
        sceneView.scene = scene

        sceneView.session.delegate = self

        labelerButton.addTarget(self, action: #selector(self.buttonReleased), for: UIControl.Event.touchUpInside)
        labelerButton.addTarget(self, action: #selector(self.buttonReleased), for: UIControl.Event.touchDragExit)
        labelerButton.addTarget(self, action: #selector(self.buttonPushed), for: UIControl.Event.touchDown)

        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            print("Camera not available")
        }
    }

    @objc
    private func buttonPushed(sender: UIButton) {
        sender.alpha = 0.8
    }

    @objc
    private func buttonReleased(sender: UIButton) {
        sender.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        configuration.maximumNumberOfTrackedImages = 4

        // Run the view's session
        self.sceneView.session.run(configuration)
        model.updateModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    // Gets callsed when an image anchor is first detected on the screen
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        let node = SCNNode()

        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        let name = (imageAnchor.referenceImage.name ?? "object")//.replacingOccurrences(of: " ", with: "\n")

        let label = SCNText(string: name, extrusionDepth: 0)
        label.firstMaterial?.diffuse.contents = UIColor.brown // UIColor.black
        label.firstMaterial?.specular.contents = UIColor.black
        label.firstMaterial?.shininess = 0.75
//            label.firstMaterial?.transparency = 0.4
        label.subdivisionLevel = 2
        label.font = UIFont(name: "HelveticaNeue-Light", size: 13)

        let labelNode = SCNNode(geometry: label)
        labelNode.position = node.position // SCNVector3(0.1, 0.3, 0)
        labelNode.position.z -= 0.00
        labelNode.position.y -= 0.07
        labelNode.position.x -= 0.025
        labelNode.scale = SCNVector3(Float(imageAnchor.referenceImage.physicalSize.width) * 0.01,
                                     Float(imageAnchor.referenceImage.physicalSize.height) * 0.01,
                                     0.01)
        
        labelNode.eulerAngles.x = -.pi / 2
        
        

        node.addChildNode(labelNode)

        if let translation = ROGoogleTranslate.translations[LanguageAPI.languageValue]?[name] {
            node.addChildNode(makeTranslationNode(translation, position: labelNode.position, scale: labelNode.scale))
        }

        return node
    }

    // Gets called every frame an image anchor is being rendered
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Check if this label has a translation
        guard
            node.childNodes.count < 2,
            let imageAnchor = anchor as? ARImageAnchor,
            let label = imageAnchor.name
        else { return }
//        print(LanguageAPI.languageValue)
        // If there was no translation, try to set it now
        let params = ROGoogleTranslateParams(source: "en", target: LanguageAPI.languageValue, text: label)
        ROGoogleTranslate.translate(params: params) { [weak self] translation in
            guard
                let `self` = self,
                let translation = translation,
                let labelNode = node.childNodes.first
            else { return }
            node.addChildNode(self.makeTranslationNode(translation, position: labelNode.position, scale: labelNode.scale))
        }
    }

    @IBAction func takePhoto() {
        guard let pixelBuffer = sceneView.session.currentFrame?.capturedImage else { print("Failed to capture image"); return }

        model.runModel(on: pixelBuffer) { [weak self] label, image, confidence in
            guard let `self` = self else { return }

            let arImage = ARReferenceImage(image, orientation: .left, physicalWidth: 0.2)
            let confidencePercentage = String(format: "%.2f", confidence * 100)
            let message = "Is \"\(label)\" the correct label for this object? \n\n\(confidencePercentage)% confidence"
            
            self.alertController = UIAlertController(title: label, message: message, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                self.storageContoller.saveImageWithLabel(pixelBuffer: pixelBuffer, label: label)
                self.translate(label, for: arImage)
            }
            
            confirmAction.isEnabled = true
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { _ in
                self.alertController = UIAlertController(title: "Change Label", message: "What should this be labeled?", preferredStyle: .alert)
                let addLabel = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                    guard
                        let `self` = self,
                        let label = self.alertController?.textFields?[0].text
                    else { return }
                    self.storageContoller.saveImageWithLabel(pixelBuffer: pixelBuffer, label: label)
                    self.translate(label, for: arImage)
                }
                
                addLabel.isEnabled = false
                
                let cancelLabel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                
                self.alertController?.addTextField { textField in
                    textField.delegate = self
                    textField.placeholder = "Enter label for Image"
                    textField.addTarget(self, action: #selector(self.alertTextFieldDidChange), for: .editingChanged)
                }

                self.alertController?.addAction(addLabel)
                self.alertController?.addAction(cancelLabel)
                
                guard let alert = self.alertController else { return }
                
                self.present(alert, animated: true, completion: nil)
            }
            
            self.alertController?.addAction(confirmAction)
            self.alertController?.addAction(cancelAction)
            
            guard let alert = self.alertController else { return }
            self.present(alert, animated: true, completion: nil)
        }
    }

    // Makes node for the translation label, position and scale should be from its label node
    private func makeTranslationNode(_ text: String, position: SCNVector3, scale: SCNVector3) -> SCNNode {
        let translationLabel = SCNText(string: text, extrusionDepth: 0)
        translationLabel.firstMaterial?.diffuse.contents = UIColor.green
        translationLabel.firstMaterial?.specular.contents = UIColor.black
        translationLabel.firstMaterial?.shininess = 0.75
        translationLabel.subdivisionLevel = 2
        translationLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10)

        let translationNode = SCNNode(geometry: translationLabel)
        translationNode.position = position
        translationNode.position.z += 0.015
        translationNode.eulerAngles.x = -.pi / 2
        translationNode.scale = scale
        return translationNode
    }

    // Translates the text sets the image anchor and translation
    private func translate(_ text: String, for arImage: ARReferenceImage) {
//        print(LanguageAPI.languageValue)
        let params = ROGoogleTranslateParams(source: "en", target: LanguageAPI.languageValue, text: text)
        ROGoogleTranslate.translate(params: params) { _ in
            arImage.name = text
            self.imageAnchors = self.imageAnchors.union(Set([arImage]))
        }
    }

    // Ensures user cannot enter in an empty string
    @objc
    private func alertTextFieldDidChange(_ sender: UITextField) {
        guard let count = sender.text?.replacingOccurrences(of: " ", with: "").count else {
            alertController?.actions[0].isEnabled = true
            return
        }

        alertController?.actions[0].isEnabled = count > 0
    }

    // Ensures user cannot enter in too many characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        guard range.length + range.location <= currentCharacterCount else { return false}
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= maxCharactersAllowedForLabel
    }

    private func loadImageAnchors() {
        guard
            let imagePathDict = UserDefaults.standard.dictionary(forKey: StorageController.imagePathKey) as? [String: String],
            let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }

        var images = Set<ARReferenceImage>()
        for (path, label) in imagePathDict {
            guard
                let imageData = fileManager.contents(atPath: documentPath.appendingPathComponent(path).path),
                let uiImage = UIImage(data: imageData),
                let cgImage = uiImage.cgImage
            else {
                print("Could not convert image data at path: \(path) to image")
                return
            }
            
            let arReferenceImage = ARReferenceImage(cgImage, orientation: .left, physicalWidth: 0.2)
            arReferenceImage.name = label
            images.insert(arReferenceImage)
        }
        imageAnchors = images
        
    }
    
}
