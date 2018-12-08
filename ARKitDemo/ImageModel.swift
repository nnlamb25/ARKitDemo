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
    
    var model: VNCoreMLModel

    init() {
        do {
            self.model = try VNCoreMLModel(for: NewMLModel().model)
        } catch {
            fatalError("Could not find coreML model")
        }
    }
    
    func updateModel(){
        let modelNumber = SelectedMLModel.indexPath
        
        switch modelNumber {
        case 0:
            do {
                self.model = try VNCoreMLModel(for: NewMLModel().model)
            } catch {
                fatalError("Could not find coreML model")
            }
        case 1:
            do {
                self.model = try VNCoreMLModel(for: PetsML().model)
            } catch {
                fatalError("Could not find coreML model")
            }
        default:
            do {
                self.model = try VNCoreMLModel(for: NewMLModel().model)
            } catch {
                fatalError("Could not find coreML model")
            }
        }
    }

    // Runs the machine learning model and returns value to closure
    func runModel(on pixelBuffer: CVPixelBuffer, closure: @escaping (String, CVPixelBuffer, VNConfidence)->()) {
        let request = VNCoreMLRequest(model: model) { finishedReq, err in
            guard
                let results = finishedReq.results as? [VNClassificationObservation],
                let firstObservation = results.first
            else { return }

            print("\(firstObservation.confidence): \(firstObservation.identifier)")
            closure(firstObservation.identifier, pixelBuffer, firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
