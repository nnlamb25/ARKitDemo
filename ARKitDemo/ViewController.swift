//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 10/2/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MobileCoreServices
import VideoToolbox

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var photoButton: UIButton!
    var alertController: UIAlertController?
    
    // Create a session configuration
    var configuration = ARImageTrackingConfiguration()

    var imageAnchors = Set<ARReferenceImage>() {
            didSet {
                self.configuration.trackingImages = imageAnchors
                sceneView.session.run(configuration)
            }
        }
    
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

        photoButton.addTarget(self, action: #selector(self.buttonPushed), for: UIControl.Event.touchUpInside)
        photoButton.addTarget(self, action: #selector(self.buttonReleased), for: UIControl.Event.touchDown)

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

        imageAnchors = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) ?? []

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

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        let node = SCNNode()

        guard let imageAnchor = anchor as? ARImageAnchor else { return node }
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)

        plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.0) // alpha: 0.3)

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2

        let label = SCNText(string: imageAnchor.referenceImage.name ?? "object", extrusionDepth: 0)
        label.firstMaterial?.diffuse.contents = UIColor.white // UIColor.black
        label.firstMaterial?.specular.contents = UIColor.black
        label.firstMaterial?.shininess = 0.75
//            label.firstMaterial?.transparency = 0.4
        label.subdivisionLevel = 2
        label.font = UIFont(name: "arial", size: 15)

        let labelNode = SCNNode(geometry: label)
        labelNode.position = planeNode.position // SCNVector3(0.1, 0.3, 0)
        labelNode.scale = SCNVector3(Float(imageAnchor.referenceImage.physicalSize.width) * 0.01,
                                     Float(imageAnchor.referenceImage.physicalSize.height) * 0.01,
                                     0.01)

        planeNode.addChildNode(labelNode)

        if imageAnchor.referenceImage.name == "ship" {
            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            let shipNode = shipScene.rootNode.childNodes.first!
            shipNode.position = SCNVector3Zero
            shipNode.position.z = 0.15
            planeNode.addChildNode(shipNode)
        }

        node.addChildNode(planeNode)
        return node
    }

    @IBAction func takePhoto() {
        guard let pixelBuffer = sceneView.session.currentFrame?.capturedImage else { print("Failed to capture image"); return }

        let arImage = ARReferenceImage(pixelBuffer, orientation: CGImagePropertyOrientation.left, physicalWidth: 0.2)

        self.alertController = UIAlertController(title: "Enter Label", message: "Enter label for image", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard
                let `self` = self,
                let label = self.alertController?.textFields?[0].text
            else { return }

            arImage.name = label
            self.imageAnchors = self.imageAnchors.union(Set([arImage]))
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        alertController?.addTextField { textField in
            textField.placeholder = "Enter label for Image"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange), for: .editingChanged)
        }

        alertController?.addAction(confirmAction)
        alertController?.addAction(cancelAction)

        guard let alert = alertController else { return }

        self.present(alert, animated: true, completion: nil)
    }

    @objc
    private func alertTextFieldDidChange(_ sender: UITextField) {
        guard let count = sender.text?.count else {
            alertController?.actions[0].isEnabled = false
            return
        }

        alertController?.actions[0].isEnabled = count > 0
    }
}
