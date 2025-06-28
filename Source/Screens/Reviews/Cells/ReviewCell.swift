import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Имя фамилия.
    let fullName: NSAttributedString
    /// Имадж звезд рейтинга.
    let ratingImage: UIImage
    /// Ссылки на картинки
    let photoUrls: [String]
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onChangeReviewTextState: (UUID, ReviewTextState) -> Void
    /// Стейт текста относительно отображения текста отзыва.
    var textState: ReviewTextState = .collapsed

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.fullNameLabel.attributedText = fullName
        cell.reviewTextLabel.attributedText = reviewText
        cell.ratingImageView.image = ratingImage
        cell.reviewPhotosView.configure(with: photoUrls)
        cell.reviewTextLabel.numberOfLines = textState.maxLines
        cell.createdLabel.attributedText = created
        cell.showMoreButton.setAttributedTitle(textState.buttonTitle, for: .normal)
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Internal

extension ReviewCellConfig {
    
    enum ReviewTextState {
        case collapsed
        case expanded
        
        var maxLines: Int {
            switch self {
            case .collapsed:
                return 3
            case .expanded:
                return 0
            }
        }
        
        var buttonTitle: NSAttributedString {
            switch self {
            case .collapsed:
                return Config.showMoreText
            case .expanded:
                return Config.hideText
            }
        }
    }
    
}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

    /// Текст кнопки "Скрыть".
    static let hideText = "Скрыть"
        .attributed(font: .showMore, color: .showMore)
    
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let avatarImageView = UIImageView()
    fileprivate let fullNameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewPhotosView = ReviewPhotosView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarImageViewFrame
        fullNameLabel.frame = layout.fullNameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewPhotosView.frame = layout.reviewPhotosViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reviewPhotosView.prepareForReuse()
    }
    
}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupReviewTextLabel()
        setupFullNameLabel()
        setupRatingView()
        setupReviewPhotoView()
        setupCreatedLabel()
        setupShowMoreButton()
        setupAvatarImageView()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.image = UIImage(named: "l5w5aIHioYc")
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
    }
    
    func setupFullNameLabel() {
        contentView.addSubview(fullNameLabel)
    }
    
    func setupRatingView() {
        contentView.addSubview(ratingImageView)
        ratingImageView.contentMode = .scaleAspectFit
    }
    
    func setupReviewPhotoView() {
        contentView.addSubview(reviewPhotosView)
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.titleLabel?.lineBreakMode = .byWordWrapping
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
    }
    
}

// MARK: - Actions

private extension ReviewCell {
    
    @objc
    func showMoreTapped() {
        guard let config else { return }
        let newState: ReviewCellConfig.ReviewTextState = config.textState == .collapsed ? .expanded : .collapsed
        config.onChangeReviewTextState(config.id, newState)
    }
    
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()
    private static let hideButtonSize = Config.hideText.size()
    
    // MARK: - Фреймы
    
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var fullNameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var reviewPhotosViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0
    
    // MARK: - Расчёт высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let leftOffset = insets.left + Self.avatarSize.width + avatarToUsernameSpacing
        let contentWidth = maxWidth - leftOffset - insets.right
        var maxY = insets.top
        
        maxY = layoutAvatarAndName(config: config, topY: maxY, leftOffset: leftOffset, contentWidth: contentWidth)
        maxY = layoutRating(config: config, topY: maxY, leftOffset: leftOffset)
        maxY = layoutPhotos(config: config, topY: maxY, leftOffset: leftOffset)
        maxY = layoutReviewText(config: config, topY: maxY, leftOffset: leftOffset, contentWidth: contentWidth)
        maxY = layoutCreatedLabel(config: config, topY: maxY, leftOffset: leftOffset, contentWidth: contentWidth)
        
        return max(maxY, avatarImageViewFrame.maxY) + insets.bottom
    }
    
}

extension ReviewCellLayout {
    
    // MARK: - Расчет фреймов
    
    private func layoutAvatarAndName(
        config: Config,
        topY: CGFloat,
        leftOffset: CGFloat,
        contentWidth: CGFloat
    ) -> CGFloat {
        avatarImageViewFrame = CGRect(origin: CGPoint(x: insets.left, y: topY), size: Self.avatarSize)

        fullNameLabelFrame = CGRect(
            origin: CGPoint(x: leftOffset, y: topY),
            size: config.fullName.boundingRect(width: contentWidth).size
        )

        return fullNameLabelFrame.maxY + usernameToRatingSpacing
    }

    private func layoutRating(config: Config, topY: CGFloat, leftOffset: CGFloat) -> CGFloat {
        ratingImageViewFrame = CGRect(origin: CGPoint(x: leftOffset, y: topY), size: config.ratingImage.size)
        return ratingImageViewFrame.maxY + ratingToTextSpacing
    }

    private func layoutPhotos(config: Config, topY: CGFloat, leftOffset: CGFloat) -> CGFloat {
        guard !config.photoUrls.isEmpty else { return topY }

        let photoCount = min(config.photoUrls.count, 5)
        let totalWidth = CGFloat(photoCount) * 55 + CGFloat(photoCount - 1) * 8

        reviewPhotosViewFrame = CGRect(
            origin: CGPoint(x: leftOffset, y: topY + ratingToPhotosSpacing),
            size: CGSize(width: totalWidth, height: Self.photoSize.height)
        )

        return reviewPhotosViewFrame.maxY + photosToTextSpacing
    }

    private func layoutReviewText(
        config: Config,
        topY: CGFloat,
        leftOffset: CGFloat,
        contentWidth: CGFloat
    ) -> CGFloat {
        guard !config.reviewText.isEmpty() else {
            showMoreButtonFrame = .zero
            return topY
        }

        let fontLineHeight = config.reviewText.font()?.lineHeight ?? 0
        let maxHeight = fontLineHeight * CGFloat(config.textState.maxLines)
        let actualHeight = config.reviewText.boundingRect(width: contentWidth).height

        let showShowMoreButton = actualHeight > maxHeight
        let limitedTextSize = config.reviewText.boundingRect(width: contentWidth, height: maxHeight).size

        reviewTextLabelFrame = CGRect(
            origin: CGPoint(x: leftOffset, y: topY),
            size: limitedTextSize
        )

        var currentMaxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing

        if showShowMoreButton {
            let buttonSize = config.textState == .expanded ? Self.hideButtonSize : Self.showMoreButtonSize
            showMoreButtonFrame = CGRect(origin: CGPoint(x: leftOffset, y: currentMaxY), size: buttonSize)
            currentMaxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        return currentMaxY
    }

    private func layoutCreatedLabel(
        config: Config,
        topY: CGFloat,
        leftOffset: CGFloat,
        contentWidth: CGFloat
    ) -> CGFloat {
        createdLabelFrame = CGRect(
            origin: CGPoint(x: leftOffset, y: topY),
            size: config.created.boundingRect(width: contentWidth).size
        )
        return createdLabelFrame.maxY
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
