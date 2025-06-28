import UIKit

final class AsyncImageView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        enum Error {
            static let value: String = "init(coder:) has not been implemented"
        }
        
        enum Image {
            static let contentMode: UIView.ContentMode = .scaleAspectFill
            static let clipsToBounds: Bool = true
            static let backgroundColor: UIColor = .clear
        }
    }
    
    // MARK: - UI Compontents
    
    private let shimmerView: ShimmerView = ShimmerView()
    private let image: UIImageView = UIImageView()
    
    // MARK: - Private variables
    
    private var currentLoadingURL: URL?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.Error.value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.frame = bounds
        image.frame = bounds
    }
    
}
    
// MARK: - Internal

extension AsyncImageView {
    
    func reuse() {
        currentLoadingURL = nil
        image.image = nil
        shimmerView.isHidden = false
        shimmerView.startShimmering()
    }
    
    func loadImage(_ imageUrl: URL) {
        guard currentLoadingURL != imageUrl else { return }
        
        currentLoadingURL = imageUrl
        if imageUrl.absoluteString.contains("http://") {
            return
        }
        
        if let img = ImageCache.shared.getImage(forKey: imageUrl.absoluteString) {
            image.image = img
            shimmerView.isHidden = true
            shimmerView.stopShimmering()
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
            guard let data = data, error == nil, let img = UIImage(data: data) else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard self?.currentLoadingURL == imageUrl else { return }
                ImageCache.shared.setImage(image: img, forkey: imageUrl.absoluteString)
                self?.image.image = img
                self?.shimmerView.isHidden = true
                self?.shimmerView.stopShimmering()
            }
        }.resume()
    }
    
}

// MARK: - Private

private extension AsyncImageView {
    
    func setUp() {
        image.contentMode = Constants.Image.contentMode
        image.clipsToBounds = Constants.Image.clipsToBounds
        image.backgroundColor = Constants.Image.backgroundColor
        shimmerView.startShimmering()
        
        addSubview(shimmerView)
        addSubview(image)
    }
    
}
