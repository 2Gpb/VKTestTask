import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        reviewsView.refreshControl.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.refreshReviews()
            },
            for: .valueChanged
        )
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.reviewsView.tableView.reloadData()
                
                if self.reviewsView.refreshControl.isRefreshing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.reviewsView.refreshControl.endRefreshing()
                    }
                }
            }
        }
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                guard let self else { return }
                
                isLoading
                ? self.reviewsView.activityIndicator.startAnimating()
                : self.reviewsView.activityIndicator.stopAnimating()
            }
        }
    }
    
}
