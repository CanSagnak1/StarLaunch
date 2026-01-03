//
//  SearchViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import UIKit

final class SearchViewController: UIViewController {

    private let viewModel: LaunchListViewModel
    private weak var coordinator: MainCoordinator?
    private weak var tabCoordinator: MainTabBarController?
    private var cancellables = Set<AnyCancellable>()

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

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search launches..."
        controller.searchBar.barStyle = .black
        controller.searchBar.searchTextField.textColor = .white
        controller.searchBar.searchTextField.backgroundColor = Colors.cardBackground
        controller.searchBar.tintColor = Colors.accentPurple
        return controller
    }()

    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilters)
        )
        button.tintColor = .white
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(LaunchCell.self, forCellReuseIdentifier: LaunchCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.configure(with: .noSearchResults)
        return view
    }()

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

    @objc private func refreshForLanguageChange() {
        title = L10n.searchTitle
        searchController.searchBar.placeholder = L10n.searchPlaceholder

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tableView.reloadData()

        if !tableView.isHidden {
        } else {
            let isSearching = !searchController.searchBar.text.isNilOrEmpty
            if isSearching && viewModel.filteredLaunches.isEmpty {
                emptyStateView.configure(with: .noSearchResults)
            }
        }
    }

    private func bindViewModel() {
        viewModel.$filteredLaunches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshForLanguageChange()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = filterButton
        definesPresentationContext = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        view.addSubview(starsOverlayView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }


    @objc private func showFilters() {
        HapticManager.shared.buttonTap()
        let alert = UIAlertController(
            title: L10n.searchSortBy, message: nil, preferredStyle: .actionSheet)

        for option in FilterCriteria.SortOption.allCases {
            let action = UIAlertAction(title: option.localizedName, style: .default) {
                [weak self] _ in
                HapticManager.shared.selectionChanged()
                self?.viewModel.sortBy(option)
            }
            if viewModel.currentSortOption == option {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }

        if viewModel.activeFiltersCount > 0 {
            alert.addAction(
                UIAlertAction(title: L10n.searchResetFilters, style: .destructive) {
                    [weak self] _ in
                    HapticManager.shared.warning()
                    self?.viewModel.resetFilters()
                })
        }

        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = filterButton
        }

        present(alert, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.search(query)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredLaunches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LaunchCell.reuseID, for: indexPath) as? LaunchCell
        else {
            return UITableViewCell()
        }
        let launch = viewModel.filteredLaunches[indexPath.row]
        cell.configure(with: launch)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticManager.shared.navigation()
        tableView.deselectRow(at: indexPath, animated: true)
        let launch = viewModel.filteredLaunches[indexPath.row]
        if let coordinator = coordinator {
            coordinator.showLaunchDetail(launchID: launch.id, launchName: launch.name)
        } else if let tabCoordinator = tabCoordinator {
            tabCoordinator.showLaunchDetail(launchID: launch.id, launchName: launch.name)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.4,
            delay: 0.03 * Double(indexPath.row % 15),
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut],
            animations: {
                cell.transform = .identity
                cell.alpha = 1
            }
        )
    }
}

extension Optional where Wrapped == String {
    fileprivate var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
