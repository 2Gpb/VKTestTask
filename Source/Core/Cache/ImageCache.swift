//
//  ImageCache.swift
//  UpNews
//
//  Created by Peter on 04.02.2025.
//

import UIKit

final class ImageCache {
    // MARK: - Singleton
    static let shared: ImageCache = ImageCache()
    
    // MARK: - Private fields
    private let cache: NSCache = NSCache<NSString, UIImage>()
    private let queue: DispatchQueue = DispatchQueue(label: "com.upnews.imageCache")
    
    // MARK: - Methods
    func setImage(image: UIImage, forkey key: String) {
        queue.async {
            self.cache.setObject(image, forKey: key as NSString)
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        queue.sync {
            cache.object(forKey: key as NSString)
        }
    }
    
    func clearCache() {
        queue.async {
            self.cache.removeAllObjects()
        }
    }
}
