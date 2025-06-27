import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let refreshControl: UIRefreshControl = UIRefreshControl()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setUpRefresh()
        setupTableView()
        setupActivityIndicator()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.refreshControl = refreshControl
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(CountCell.self, forCellReuseIdentifier: CountCellConfig.reuseId)
    }
    
    private func setUpRefresh() {
        refreshControl.tintColor = .lightGray
    }
    
    private func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.color = .lightGray
        activityIndicator.isUserInteractionEnabled = false
    }

}
