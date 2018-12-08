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
    public var target = LanguageAPI.languageValue
    public var text = "Hello, World!"
}


/// Offers easier access to the Google Translate API
open class ROGoogleTranslate {
    
    // A dictionary of translations with their label as the key
    static var translations: [String: [String: String]] = UserDefaults.standard.dictionary(forKey: "translations") as? [String: [String: String]] ?? [:]{
        didSet {
            UserDefaults.standard.set(translations, forKey: "translations")
        }
    }
    
    /// Store here the Google Translate API Key
    private var apiKey = "**Removed**"
    private var ddosGuard = true
    
    ///
    /// Translate a phrase from one language into another
    ///
    /// - parameter params:   ROGoogleTranslate Struct contains all the needed parameters to translate with the Google Translate API
    /// - parameter callback: The translated string will be returned in the callback
    ///
    static func translate(params:ROGoogleTranslateParams, guarded: Bool = true, callback: @escaping (_ translatedText: String?) -> ()) {
        // Make sure we haven't already translated this before, if so just use that translation
        if let repeatedTranslation = ROGoogleTranslate.translations[params.target]?[params.text] {
            callback(repeatedTranslation)
            return
        }


        guard
            ddosGuard || !guarded,
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
                    let translationData = jsonData["translations"] as? [NSDictionary],
                    let translation = translationData.first as? [String : Any],
                    let translatedText = translation["translatedText"] as? String
                else {
                    print("Failed to get translation")
                    callback(nil)
                    return
                }

                if self.translations[params.target] == nil {
                    self.translations[params.target] = [params.text: translatedText]
                } else {
                    self.translations[params.target]![params.text] = translatedText
                }

                print("Translated '\(params.text)' from \(params.source) to '\(translatedText)' in \(params.target)")
                callback(translatedText)
            } catch {
                print("Serialization failed: \(error.localizedDescription)")
                callback(nil)
            }
        }

        ddosGuard = false
        httprequest.resume()

        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            ddosGuard = true
        }
    }
}
