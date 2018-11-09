//
//  ImageModel.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 10/25/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import ARKit
import Foundation
import Vision

// Handles the machine learning portion of the app
class ImageModel {
    
    let model: VNCoreMLModel
    var vc: ImageHandler
    // Connects the image anchors in the ViewController.  When these are updates, the images in
    // the view controller are updated
    var imageAnchors: Set<ARReferenceImage> = [] {
        didSet { self.vc.imageAnchors = imageAnchors.union(self.vc.imageAnchors) }
    }

    // Once images are detected, the labels are set in the view controller (image handler)
    init(with vc: ImageHandler) {
        do {
            self.model = try VNCoreMLModel(for: BetterImage().model)
        } catch {
            fatalError("Could not find coreML model")
        }

        self.vc = vc
    }

    // Runs the machine learning model and sets a label for the image on the screen for imageAnchors
    func runModel(on frame: ARFrame, closure: @escaping (String, ARFrame)->()) {
        let request = VNCoreMLRequest(model: model) { finishedReq, err in
            guard
                let results = finishedReq.results as? [VNClassificationObservation],
                let firstObservation = results.first,
                firstObservation.confidence > 0.8
            else { return }

            print("\(firstObservation.confidence): \(firstObservation.identifier)")
            closure(firstObservation.identifier, frame)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:]).perform([request])
    }
}
