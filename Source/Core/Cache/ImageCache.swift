import UIKit

final class ImageCache {
    
    // MARK: - Singleton
    
    static let shared: ImageCache = ImageCache()
    
    // MARK: - Properties
    
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
