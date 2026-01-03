//
//  LaunchListViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import UIKit

final class LaunchListViewController: UIViewController {

    let viewModel: LaunchListViewModel
    private weak var coordinator: MainCoordinator?
    private weak var tabCoordinator: MainTabBarController?
    var cancellables = Set<AnyCancellable>()

    private let gradientBackgroundLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#0A0F1C").cgColor,
            UIColor(hex: "#1E1B4B").cgColor,
            UIColor(hex: "#0F172A").cgColor,
        ]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let starsOverlayView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background_2")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.25
        return imageView
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(LaunchCell.self, forCellReuseIdentifier: LaunchCell.reuseID)
        tableView.register(SkeletonCell.self, forCellReuseIdentifier: SkeletonCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = Colors.titleColor
        control.attributedTitle = NSAttributedString(
            string: "Pull to refresh",
            attributes: [.foregroundColor: Colors.subtitleColor]
        )
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let offlineBanner: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.warning.withAlphaComponent(0.9)
        view.layer.cornerRadius = 8
        view.isHidden = true

        let iconView = UIImageView(image: UIImage(systemName: "wifi.slash"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.tag = 100

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    private var isShowingSkeleton = true
    private let skeletonCellCount = 5

    init(viewModel: LaunchListViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    init(viewModel: LaunchListViewModel, coordinator: MainTabBarController?) {
        self.viewModel = viewModel
        self.tabCoordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cancellables.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bindViewModel()
        viewModel.fetchLaunches()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshForLanguageChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
        refreshForLanguageChange()
    }


    @objc func refreshForLanguageChange() {
        title = L10n.launchesTitle
        refreshControl.attributedTitle = NSAttributedString(
            string: L10n.commonPullToRefresh,
            attributes: [.foregroundColor: Colors.subtitleColor]
        )

        if let config = emptyStateView.currentConfiguration,
            config.title == L10n.emptyNoInternetTitle || config.title == "No Internet Connection"
        {  // Check both old and new to be safe or just re-set if needed
        }
        updateEmptyState()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    private func setupNavigationBar() {
        self.title = "Launches"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: Colors.titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: Colors.titleColor]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(showSearch)
        )
        searchButton.tintColor = Colors.titleColor
        navigationItem.rightBarButtonItem = searchButton
    }

    @objc private func showSearch() {
        HapticManager.shared.navigation()
        if let coordinator = coordinator {
            coordinator.showSearch()
        } else if let tabCoordinator = tabCoordinator {
            tabCoordinator.showSearch()
        }
    }

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(offlineBanner)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            offlineBanner.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            offlineBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            offlineBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            offlineBanner.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        var config = EmptyStateView.Configuration.noInternet
        config = EmptyStateView.Configuration(
            image: UIImage(systemName: "wifi.slash"),
            title: L10n.emptyNoInternetTitle,
            message: L10n.errorNoInternet,
            actionTitle: L10n.retry,
            action: { [weak self] in
                self?.viewModel.refreshLaunches()
            }
        )
        emptyStateView.configure(with: config)
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                if self.viewModel.launchItems.isEmpty {
                    self.isShowingSkeleton = isLoading
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)

        viewModel.$isRefreshing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRefreshing in
                if !isRefreshing {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.$launchItems
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                guard let self = self else { return }

                self.isShowingSkeleton = false

                let oldItemCount = self.tableView.numberOfRows(inSection: 0)

                if oldItemCount == 0 || oldItemCount == self.skeletonCellCount {
                    self.tableView.reloadData()
                } else {
                    let newItemCount = newItems.count
                    if newItemCount > oldItemCount {
                        let indexPathsToInsert = (oldItemCount..<newItemCount).map {
                            IndexPath(row: $0, section: 0)
                        }

                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexPathsToInsert, with: .fade)
                        self.tableView.endUpdates()
                    }
                }

                self.updateEmptyState()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.isShowingSkeleton = false
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        viewModel.$isOfflineMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOffline in
                self?.offlineBanner.isHidden = !isOffline
                if isOffline, let label = self?.offlineBanner.viewWithTag(100) as? UILabel {
                    label.text = "📴 Offline Mode - \(self?.viewModel.offlineInfo ?? "")"
                }
            }
            .store(in: &cancellables)
    }

    @objc private func handleRefresh() {
        HapticManager.shared.pullToRefresh()
        viewModel.refreshLaunches()
    }

    private func updateEmptyState() {
        let isEmpty =
            viewModel.launchItems.isEmpty && !viewModel.isLoading && viewModel.errorMessage != nil
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

extension LaunchListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingSkeleton {
            return skeletonCellCount
        }
        return viewModel.launchItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingSkeleton {
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: SkeletonCell.reuseID, for: indexPath) as? SkeletonCell
            else {
                return UITableViewCell()
            }
            cell.startAnimating()
            return cell
        }

        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LaunchCell.reuseID, for: indexPath) as? LaunchCell
        else {
            return UITableViewCell()
        }
        let launch = viewModel.launchItems[indexPath.row]
        cell.configure(with: launch)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isShowingSkeleton else { return }

        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLaunch = viewModel.launchItems[indexPath.row]

        if let coordinator = coordinator {
            coordinator.showLaunchDetail(
                launchID: selectedLaunch.id, launchName: selectedLaunch.name)
        } else if let tabCoordinator = tabCoordinator {
            tabCoordinator.showLaunchDetail(
                launchID: selectedLaunch.id, launchName: selectedLaunch.name)
        } else {
            let detailViewModel = LaunchDetailViewModel(launchID: selectedLaunch.id)
            let detailVC = LaunchDetailViewController(viewModel: detailViewModel)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        guard !isShowingSkeleton else { return }

        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height / 2)
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row % 10),
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                cell.transform = .identity
                cell.alpha = 1
            }
        )
    }

    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !isShowingSkeleton else { return nil }

        let launch = viewModel.launchItems[indexPath.row]
        let isFavorite = viewModel.isFavorite(launch.id)

        let favoriteAction = UIContextualAction(style: .normal, title: nil) {
            [weak self] _, _, completion in
            self?.viewModel.toggleFavorite(launch)
            completion(true)
        }

        favoriteAction.image = UIImage(systemName: isFavorite ? "star.slash.fill" : "star.fill")
        favoriteAction.backgroundColor = isFavorite ? .systemGray : .systemYellow

        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isShowingSkeleton else { return }

        let position = scrollView.contentOffset.y
        let tableViewContentHeight = tableView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if position > (tableViewContentHeight - scrollViewHeight - 200) {
            viewModel.fetchLaunches()
        }
    }
}

extension LaunchListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard !isShowingSkeleton else { return }

        for indexPath in indexPaths {
            guard indexPath.row < viewModel.launchItems.count else { continue }
            let launch = viewModel.launchItems[indexPath.row]
            if let urlString = launch.image, let url = URL(string: urlString) {
                Task {
                    _ = await ImageLoader.shared.loadImage(from: url)
                }
            }
        }
    }
}
