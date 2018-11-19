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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var labelerButton: UIButton!
    var alertController: UIAlertController?
    lazy var translator = ROGoogleTranslate()
    lazy var model = ImageModel()

    var timer: Timer?

    // Create a session configuration
    var configuration = ARImageTrackingConfiguration()

    var imageAnchors = Set<ARReferenceImage>() {
            didSet{
                self.configuration.trackingImages = imageAnchors
                sceneView.session.run(configuration)
            }
        }
    private var maxCharactersAllowedForLabel = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
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

//        imageAnchors = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) ?? []

        configuration.maximumNumberOfTrackedImages = 4

        // Run the view's session
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        label.font = UIFont(name: "HelveticaNeue-Light", size: 10)

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
        
        if imageAnchor.referenceImage.name == "ship" {
            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            let shipNode = shipScene.rootNode.childNodes.first!
            shipNode.position = labelNode.position
            shipNode.position.z += 0.05
            shipNode.eulerAngles.x = -.pi / 2
            node.addChildNode(shipNode)
        }

        if let translation = translator.translations[name] {
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

        // If there was no translation, try to set it now
        let params = ROGoogleTranslateParams(source: "en", target: "de", text: label)
        self.translator.translate(params: params) { [weak self] translation in
            guard
                let `self` = self,
                let translation = translation,
                let labelNode = node.childNodes.first
            else { return }
            self.translator.translations[label] = translation
            node.addChildNode(self.makeTranslationNode(translation, position: labelNode.position, scale: labelNode.scale))
        }
    }

    @IBAction func takePhoto() {
        guard let pixelBuffer = sceneView.session.currentFrame?.capturedImage else { print("Failed to capture image"); return }

        model.runModel(on: pixelBuffer) { [weak self] label, image in
            guard let `self` = self else { return }

            let arImage = ARReferenceImage(image, orientation: CGImagePropertyOrientation.left, physicalWidth: 0.2)
            
            self.alertController = UIAlertController(title: label, message: "Is \"\(label)\" the correct label for this object?", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                self?.translate(label, for: arImage)
            }
            
            confirmAction.isEnabled = true
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { _ in
                self.alertController = UIAlertController(title: "Change Label", message: "What should this be labeled?", preferredStyle: .alert)
                let addLabel = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                    guard
                        let `self` = self,
                        let label = self.alertController?.textFields?[0].text
                    else { return }
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
        let params = ROGoogleTranslateParams(source: "en", target: "de", text: text)
        self.translator.translate(params: params) { translation in
            if let translation = translation {
                self.translator.translations[text] = translation
            }
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
}
