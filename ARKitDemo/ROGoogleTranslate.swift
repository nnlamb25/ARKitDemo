//
//  ROGoogleTranslate.swift
//  ROGoogleTranslate
//
//  Created by Robin Oster on 20/10/16.
//  Copyright © 2016 prine.ch. All rights reserved.
//

import Foundation

public struct ROGoogleTranslateParams {
    
    public init(source:String, target:String, text:String) {
        self.source = source
        self.target = target
        self.text = text
    }
    
    public var source = "en"
    public var target = "de"
    public var text = "Hello, World!"
}


/// Offers easier access to the Google Translate API
open class ROGoogleTranslate {
    
    /// Store here the Google Translate API Key
    private var apiKey = "AIzaSyCqaFXCzC5eggYyRf04ftWvxV7AXDwNOlc"
    private var ddosGuard = true
    
    ///
    /// Translate a phrase from one language into another
    ///
    /// - parameter params:   ROGoogleTranslate Struct contains all the needed parameters to translate with the Google Translate API
    /// - parameter callback: The translated string will be returned in the callback
    ///
    open func translate(params:ROGoogleTranslateParams, callback: @escaping (_ translatedText: String?) -> ()) {
        
        guard
            ddosGuard,
            let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)&q=\(urlEncodedText)&source=\(params.source)&target=\(params.target)&format=text")
        else { callback(nil); return }
        
        let httprequest = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Something went wrong: \(error.localizedDescription)")
                callback(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            guard httpResponse.statusCode == 200 else {
                guard let badData = data else { return }
                print("Response [\(httpResponse.statusCode)] - \(badData)")
                callback(nil)
                return
            }
            
            do {
                guard
                    let data = data,
                    let json = try JSONSerialization.jsonObject(with: data,options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary,
                    let jsonData = json["data"] as? [String : Any],
                    let translations = jsonData["translations"] as? [NSDictionary],
                    let translation = translations.first as? [String : Any],
                    let translatedText = translation["translatedText"] as? String
                else {
                    print("Failed to get translation")
                    callback(nil)
                    return
                }

                callback(translatedText)
            } catch {
                print("Serialization failed: \(error.localizedDescription)")
                callback(nil)
            }
        }

        ddosGuard = false
        httprequest.resume()

        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.ddosGuard = true
        }
    }
}
