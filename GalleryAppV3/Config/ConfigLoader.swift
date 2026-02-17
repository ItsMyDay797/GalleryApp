//
//  ConfigLoader.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation

enum ConfigLoader {

    static func unsplashAccessKey() -> String? {
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url) as? [String: Any],
           let key = dict["UNSPLASH_ACCESS_KEY"] as? String, !key.isEmpty {
            return key
        }
        return Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String
    }
}
