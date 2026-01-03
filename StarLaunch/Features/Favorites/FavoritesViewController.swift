//
//  FavoritesViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import UIKit

final class FavoritesViewController: UIViewController {

    private weak var coordinator: MainCoordinator?
    private weak var tabCoordinator: MainTabBarController?
    private let favoritesManager = FavoritesManager.shared
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

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(LaunchCell.self, forCellReuseIdentifier: LaunchCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    init(coordinator: MainCoordinator?) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    init(coordinator: MainTabBarController?) {
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
        bindFavorites()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshForLanguageChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
        refreshForLanguageChange()
    }

    private func setupUI() {
        title = L10n.favoritesTitle
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

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

        var config = EmptyStateView.Configuration.noFavorites
        config = EmptyStateView.Configuration(
            image: UIImage(systemName: "star"),
            title: L10n.favoritesEmptyTitle,
            message: L10n.favoritesEmptyMessage,
            actionTitle: L10n.favoritesBrowse,
            action: { [weak self] in
                HapticManager.shared.buttonTap()
                if let coordinator = self?.coordinator {
                    coordinator.showLaunchList()
                } else if let tabCoordinator = self?.tabCoordinator {
                    tabCoordinator.showLaunchList()
                }
            }
        )
        emptyStateView.configure(with: config)
    }


    @objc func refreshForLanguageChange() {
        title = L10n.favoritesTitle
        emptyStateView.configure(
            with: EmptyStateView.Configuration(
                image: UIImage(systemName: "star"),
                title: L10n.favoritesEmptyTitle,
                message: L10n.favoritesEmptyMessage,
                actionTitle: L10n.favoritesBrowse,
                action: { [weak self] in
                    HapticManager.shared.buttonTap()
                    if let coordinator = self?.coordinator {
                        coordinator.showLaunchList()
                    } else if let tabCoordinator = self?.tabCoordinator {
                        tabCoordinator.showLaunchList()
                    }
                }
            ))
        tableView.reloadData()
    }

    private func bindFavorites() {
        favoritesManager.$favoriteLaunches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] launches in
                self?.tableView.reloadData()
                self?.updateEmptyState(isEmpty: launches.isEmpty)
            }
            .store(in: &cancellables)
    }

    private func updateEmptyState(isEmpty: Bool) {
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesManager.favoriteLaunches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LaunchCell.reuseID, for: indexPath) as? LaunchCell
        else {
            return UITableViewCell()
        }
        let launch = favoritesManager.favoriteLaunches[indexPath.row]
        cell.configure(with: launch)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticManager.shared.navigation()
        tableView.deselectRow(at: indexPath, animated: true)
        let launch = favoritesManager.favoriteLaunches[indexPath.row]
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
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {
            [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            HapticManager.shared.swipeAction()
            let launch = self.favoritesManager.favoriteLaunches[indexPath.row]
            self.favoritesManager.removeFavorite(launch.id)
            completion(true)
        }

        deleteAction.image = UIImage(systemName: "star.slash.fill")
        deleteAction.backgroundColor = Colors.error

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.4,
            delay: 0.05 * Double(indexPath.row % 10),
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
