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

    init() {
        do {
            self.model = try VNCoreMLModel(for: NewMLModel().model)
        } catch {
            fatalError("Could not find coreML model")
        }
    }

    // Runs the machine learning model and returns value to closure
    func runModel(on pixelBuffer: CVPixelBuffer, closure: @escaping (String, CVPixelBuffer)->()) {
        let request = VNCoreMLRequest(model: model) { finishedReq, err in
            guard
                let results = finishedReq.results as? [VNClassificationObservation],
                let firstObservation = results.first
            else { return }

            print("\(firstObservation.confidence): \(firstObservation.identifier)")
            closure(firstObservation.identifier, pixelBuffer)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
