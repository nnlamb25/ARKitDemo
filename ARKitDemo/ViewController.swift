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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()

        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main)
            else { print("No images available"); return }

        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 4

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        let node = SCNNode()

        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)

            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.3)

            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2

            let label = SCNText(string: imageAnchor.referenceImage.name ?? "object", extrusionDepth: 0)
            label.firstMaterial?.diffuse.contents = UIColor.black
            label.firstMaterial?.specular.contents = UIColor.black
            label.firstMaterial?.shininess = 0.75
//            label.firstMaterial?.transparency = 0.4
            label.subdivisionLevel = 2
            label.font = UIFont(name: "sarif", size: 20)

            let labelNode = SCNNode(geometry: label)
            labelNode.position = SCNVector3(0.1, 0.3, 0)
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
        }

        return node
    }
}
