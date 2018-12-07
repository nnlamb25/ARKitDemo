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
    
    // Save an image with meta data to the photo album
    public static func saveToPhotoAlbumWithMetadata(_ image: CGImage, label: String) {
        let uuid = "TranslateAR_" + UUID().uuidString
        let filePath = "/UserImages/\(uuid).jpg"
        let cfPath = CFURLCreateWithFileSystemPath(nil, filePath as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        
        // You can change your exif type here.
        let destination = CGImageDestinationCreateWithURL(cfPath!, "kUTTypeJPEG" as CFString, 1, nil)
        
        // Place your metadata here.
        // Keep in mind that metadata follows a standard. You can not use custom property names here.
        let tiffProperties = [
            kCGImagePropertyTIFFImageDescription as String: label,
            //kCGImagePropertyTIFFModel as String: "Your camera model"
            ] as CFDictionary
        
        let properties = [
            kCGImagePropertyExifDictionary as String: tiffProperties
            ] as CFDictionary
        
        CGImageDestinationAddImage(destination!, image, properties)
        CGImageDestinationFinalize(destination!)
        
//        try? PHPhotoLibrary.shared().performChangesAndWait {
//            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
//        }
    }
    
    // Saved an image with its label
    public static func saveImageWithLabel(pixelBuffer: CVPixelBuffer, label: String) {
        
        //Convert PixelBuffer to a CGImage
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        
        //Add metadata and save image
        saveToPhotoAlbumWithMetadata(image!, label: label)
    }
}
