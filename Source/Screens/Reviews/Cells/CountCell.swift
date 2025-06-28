import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct CountCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: CountCellConfig.self)

    let reviewCount: NSAttributedString

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = CountCellLayout()

}

// MARK: - TableCellConfig

extension CountCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? CountCell else { return }
        cell.reviewCountLabel.attributedText = reviewCount
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Cell

final class CountCell: UITableViewCell {
    
    // MARK: - Properties

    fileprivate var config: Config?

    fileprivate let reviewCountLabel = UILabel()
    
    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        reviewCountLabel.frame = layout.reviewCountLabelFrame
    }
    
}

// MARK: - Private

private extension CountCell {

    func setupCell() {
        contentView.addSubview(reviewCountLabel)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class CountCellLayout {

    // MARK: - Фреймы

    private(set) var reviewCountLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let maxY = insets.top
        let width = maxWidth - insets.left - insets.right
        let labelSize = config.reviewCount.boundingRect(width: width).size

        reviewCountLabelFrame = CGRect(
            origin: CGPoint(x: (maxWidth - labelSize.width) / 2, y: maxY),
            size: labelSize
        )

        return reviewCountLabelFrame.maxY + insets.bottom
    }

}

fileprivate typealias Config = CountCellConfig
fileprivate typealias Layout = CountCellLayout
