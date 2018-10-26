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

class ImageModel {
    
    let model: VNCoreMLModel
    var vc: ImageHandler
    var imageAnchors: Set<ARReferenceImage> = [] {
        didSet {
            print("SETTING ANCHORS")
            self.vc.imageAnchors = imageAnchors
        }
    }
    
    init(with vc: ImageHandler) {
        do {
            self.model = try VNCoreMLModel(for: BetterImage().model)
        } catch {
            fatalError("Could not find coreML model")
        }

        self.vc = vc
    }

    func runModel(on frame: ARFrame, addTo imageAnchors: inout Set<ARReferenceImage>, closure: @escaping ()->()) {
        let request = VNCoreMLRequest(model: model) { [weak self] finishedReq, err in
            guard
                let `self` = self,
                let results = finishedReq.results as? [VNClassificationObservation],
                let firstObservation = results.first,
                firstObservation.confidence > 0.8
            else { return }

            print("\(firstObservation.confidence): \(firstObservation.identifier)")

            let arImage = ARReferenceImage(frame.capturedImage, orientation: CGImagePropertyOrientation.left, physicalWidth: 0.2)
            arImage.name = firstObservation.identifier
            self.imageAnchors = self.imageAnchors.union(Set([arImage]))
            closure()
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:]).perform([request])
    }
}
