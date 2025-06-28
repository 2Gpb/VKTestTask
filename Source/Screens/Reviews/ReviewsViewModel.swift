import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    /// Замыкание, вызываемое при изменении `loadingState`.
    var onLoadingStateChange: ((Bool) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        if state.offset == 0 {
            onLoadingStateChange?(true)
        }
        
        state.shouldLoad = false
        reviewsProvider.getReviews(completion: gotReviews)
    }
    
    func refreshReviews() {
        state.offset = 0
        reviewsProvider.getReviews(completion: gotReviews)
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        defer {
            onLoadingStateChange?(false)
            onStateChange?(state)
        }
        
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            let newItems = reviews.items.map(makeReviewItem)
            
            if state.offset == 0 {
                state.items = newItems
            } else {
                state.items.append(contentsOf: newItems)
            }
            
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
            state.countItem = makeCountItemItem(reviews.count)
        } catch {
            state.shouldLoad = true
        }
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func updateReviewTextState(with id: UUID, textState: ReviewCellConfig.ReviewTextState) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.textState = textState
        state.items[index] = item
        onStateChange?(state)
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig
    typealias CountItem = CountCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let fullName = "\(review.firstName) \(review.lastName)".attributed(font: .username)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        let reviewPhotoUrls = review.photoUrls
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        
        let item = ReviewItem(
            fullName: fullName,
            ratingImage: ratingImage,
            photoUrls: reviewPhotoUrls,
            reviewText: reviewText,
            created: created,
            onChangeReviewTextState: { [weak self] id, textState in
                self?.updateReviewTextState(with: id, textState: textState)
            }
        )
        return item
    }
    
    func makeCountItemItem(_ count: Int) -> CountItem {
        let reviewCount = "\(count) отзывов".attributed(font: .reviewCount, color: .reviewCount)
        
        let item = CountItem(reviewCount: reviewCount)
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if indexPath.row == state.items.count {
            guard let config = state.countItem else { return UITableViewCell() }
            cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
            config.update(cell: cell)
        } else {
            let config = state.items[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
            config.update(cell: cell)
        }
        
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == state.items.count {
            guard let config = state.countItem else { return 0 }
            return config.height(with: tableView.bounds.size)
        } else {
            return state.items[indexPath.row].height(with: tableView.bounds.size)
        }
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
