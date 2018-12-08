//
//  StorageController.swift
//  ARKitDemo
//
//  Created by Daniel Wu on 12/7/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import VideoToolbox

public class StorageController {

    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard

    let imagePathKey = "imagePaths"
    
    // Saved an image with its label
    public func saveImageWithLabel(pixelBuffer: CVPixelBuffer, label: String) {
        
        //Convert PixelBuffer to a CGImage
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        guard let image = cgImage else {
            print("Could not save image")
            return
        }
        let uiImage = UIImage(cgImage: image)
        guard let imageData = uiImage.jpegData(compressionQuality: 1.0) else {
            print("Could not save image")
            return
        }
        
        //Add metadata and save image
        saveToPhotoAlbumWithMetadata(imageData, label: label)
    }

    // Save an image with meta data to the photo album
    private func saveToPhotoAlbumWithMetadata(_ imageData: Data, label: String) {
        let imageURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = imageURL.path
        let uuid = "\(label)_" + UUID().uuidString + ".jpg"
        let filePath = imageURL.appendingPathComponent(uuid)
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: "\(imagePath)")
            for file in files {
                if "\(imagePath)/\(file)" == filePath.path {
                    try fileManager.removeItem(atPath: filePath.path)
                }
            }
        } catch {
            print("Could not add image from document directory: \(error)")
        }
        
        do {
            try imageData.write(to: filePath, options: .atomic)
        } catch {
            print("Could not write image to filePath: \(filePath.path)")
        }

        if var imageLabelDict = userDefaults.dictionary(forKey: imagePathKey) as? [String : String] {
            imageLabelDict[uuid] = label
            userDefaults.setValue(imageLabelDict, forKey: imagePathKey)
        } else {
            userDefaults.setValue([uuid: label], forKey: imagePathKey)
        }
    }
}
