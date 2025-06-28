import UIKit

final class ReviewPhotosView: UIView {
    
    // MARK: - Properties
    
    private var photoViews: [AsyncImageView] = []
    private let maxPhotos = 5
    private let photoSize = CGSize(width: 55, height: 66)
    private let spacing: CGFloat = 8
    private let cornerRadius: CGFloat = 8
    
    // MARK: - Layout
    
    override var intrinsicContentSize: CGSize {
        let visibleCount = photoViews.filter { !$0.isHidden }.count
        guard visibleCount > 0 else { return .zero }
        let totalWidth = CGFloat(visibleCount) * photoSize.width
        + CGFloat(visibleCount - 1) * spacing
        return CGSize(width: totalWidth, height: photoSize.height)
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Internal

extension ReviewPhotosView {
    
    func prepareForReuse() {
        for photoView in photoViews {
            photoView.reuse()
            photoView.isHidden = true
        }
    }
    
    func configure(with urls: [String]) {
        photoViews.forEach { $0.isHidden = true }
        
        for (index, urlString) in urls.prefix(maxPhotos).enumerated() {
            let photoView = photoViews[index]
            photoView.isHidden = false
            if let url = URL(string: urlString) {
                photoView.loadImage(url)
            }
        }
        invalidateIntrinsicContentSize()
    }
    
}
    
// MARK: - Private

private extension ReviewPhotosView {

    func setup() {
        for i in 0..<maxPhotos {
            let photoView = AsyncImageView()
            photoView.layer.cornerRadius = cornerRadius
            photoView.clipsToBounds = true

            let x = CGFloat(i) * (photoSize.width + spacing)
            photoView.frame = CGRect(x: x, y: 0, width: photoSize.width, height: photoSize.height)

            addSubview(photoView)
            photoViews.append(photoView)
        }
        invalidateIntrinsicContentSize()
    }
    
}
