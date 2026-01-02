//
//  LaunchDetailViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import UIKit

final class LaunchDetailViewController: UIViewController {

    private var viewModel: LaunchDetailViewModel
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
        imageView.image = UIImage(named: "background_3")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.25
        return imageView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var launchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .black.withAlphaComponent(0.3)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.subtitleColor
        label.textAlignment = .center
        return label
    }()

    private lazy var missionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = Colors.titleColor.withAlphaComponent(0.9)
        return label
    }()

    private lazy var actionButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var favoriteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Favorite"
        config.image = UIImage(systemName: "star")
        config.imagePadding = 8
        config.baseBackgroundColor = Colors.buttonBackground
        config.baseForegroundColor = Colors.titleColor
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        return button
    }()

    private lazy var notificationButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Remind Me"
        config.image = UIImage(systemName: "bell")
        config.imagePadding = 8
        config.baseBackgroundColor = Colors.buttonBackground
        config.baseForegroundColor = Colors.titleColor
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(toggleNotification), for: .touchUpInside)
        return button
    }()

    private lazy var rocketInfoView = InfoRowView(
        iconSystemName: "airplane", title: "Rocket", value: "...")
    private lazy var launchPadInfoView = InfoRowView(
        iconSystemName: "location.fill", title: "Launch Pad", value: "...")
    private lazy var serviceProviderInfoView = InfoRowView(
        iconSystemName: "person.3.fill", title: "Provider", value: "...")

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            rocketInfoView, launchPadInfoView, serviceProviderInfoView,
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private lazy var crewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Colors.titleColor
        label.text = "Crew"
        label.isHidden = true
        return label
    }()

    private lazy var astronautsContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var astronautListVC: AstronautListViewController?

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            dateLabel,
            actionButtonsStack,
            missionDescriptionLabel,
            infoStackView,
            crewTitleLabel,
            astronautsContainerView,
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(20, after: dateLabel)
        stackView.setCustomSpacing(24, after: actionButtonsStack)
        stackView.setCustomSpacing(24, after: missionDescriptionLabel)
        stackView.setCustomSpacing(24, after: infoStackView)
        return stackView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = Colors.titleColor
        return indicator
    }()

    init(viewModel: LaunchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cancellables.removeAll()
    }

    override func viewDidLoad() {
        self.title = "Launch Detail"
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
        viewModel.fetchLaunchDetail()
    }

    private func setupNavigationBar() {
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareLaunch)
        )
        shareButton.tintColor = Colors.titleColor
        navigationItem.rightBarButtonItem = shareButton
    }

    @objc private func shareLaunch() {
        HapticManager.shared.buttonTap()
        guard let detail = viewModel.launchDetail else { return }

        let text = """
            🚀 \(detail.name)
            📅 \(formatDate(detail.net))
            🏢 \(detail.launchServiceProvider.name)
            📍 \(detail.pad.name)
            """

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    @objc private func toggleFavorite() {
        HapticManager.shared.favorite()
        viewModel.toggleFavorite()

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        ) { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = .identity
            }
        }
    }

    @objc private func toggleNotification() {
        HapticManager.shared.buttonTap()
        if !NotificationManager.shared.isAuthorized {
            viewModel.requestNotificationPermission { [weak self] granted in
                if granted {
                    HapticManager.shared.success()
                    self?.viewModel.toggleNotification()
                } else {
                    HapticManager.shared.warning()
                    self?.showNotificationPermissionAlert()
                }
            }
        } else {
            viewModel.toggleNotification()
        }
    }

    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive launch reminders.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func bindViewModel() {
        viewModel.$launchDetail
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] launchDetail in
                self?.updateUIWith(launchDetail)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.scrollView.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.scrollView.isHidden = false
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)

        viewModel.$isFavorite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                self?.updateFavoriteButton(isFavorite: isFavorite)
            }
            .store(in: &cancellables)

        viewModel.$isNotificationScheduled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isScheduled in
                self?.updateNotificationButton(isScheduled: isScheduled)
            }
            .store(in: &cancellables)

        viewModel.updateUI = { [weak self] launchDetail in
            DispatchQueue.main.async {
                self?.updateUIWith(launchDetail)
            }
        }
        viewModel.showError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
        viewModel.updateLoadingStatus = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        var config = favoriteButton.configuration
        config?.image = UIImage(systemName: isFavorite ? "star.fill" : "star")
        config?.title = isFavorite ? "Favorited" : "Favorite"
        config?.baseBackgroundColor =
            isFavorite ? .systemYellow.withAlphaComponent(0.3) : Colors.buttonBackground
        favoriteButton.configuration = config
    }

    private func updateNotificationButton(isScheduled: Bool) {
        var config = notificationButton.configuration
        config?.image = UIImage(systemName: isScheduled ? "bell.fill" : "bell")
        config?.title = isScheduled ? "Reminder Set" : "Remind Me"
        config?.baseBackgroundColor =
            isScheduled ? .systemBlue.withAlphaComponent(0.3) : Colors.buttonBackground
        notificationButton.configuration = config

        notificationButton.isHidden = !viewModel.canScheduleNotification
    }

    private func updateUIWith(_ launchDetail: LaunchDetail) {
        nameLabel.text = launchDetail.name
        statusLabel.text = launchDetail.status.name.uppercased()
        statusLabel.backgroundColor = statusColor(for: launchDetail.status.name)

        dateLabel.text = formatDate(launchDetail.net)

        missionDescriptionLabel.text =
            launchDetail.mission?.description ?? "No mission description available."

        rocketInfoView.updateValue(launchDetail.rocket.configuration.fullName)
        launchPadInfoView.updateValue("\(launchDetail.pad.name), \(launchDetail.pad.location.name)")
        serviceProviderInfoView.updateValue(launchDetail.launchServiceProvider.name)

        if let imageUrlString = launchDetail.image, let url = URL(string: imageUrlString) {
            Task {
                launchImageView.image = await ImageLoader.shared.loadImage(from: url)
            }
        }

        let astronauts = launchDetail.program.first?.crew?.map { $0.astronaut } ?? []
        if !astronauts.isEmpty {
            crewTitleLabel.isHidden = false
            astronautsContainerView.isHidden = false
            updateAstronauts(with: astronauts)
        } else {
            crewTitleLabel.isHidden = true
            astronautsContainerView.isHidden = true
        }
    }

    private func updateAstronauts(with astronauts: [Astronaut]) {
        if astronautListVC == nil {
            astronautListVC = AstronautListViewController(astronauts: astronauts)
            guard let astronautListVC = astronautListVC else { return }

            addChild(astronautListVC)
            astronautsContainerView.addSubview(astronautListVC.view)
            astronautListVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                astronautListVC.view.topAnchor.constraint(
                    equalTo: astronautsContainerView.topAnchor),
                astronautListVC.view.bottomAnchor.constraint(
                    equalTo: astronautsContainerView.bottomAnchor),
                astronautListVC.view.leadingAnchor.constraint(
                    equalTo: astronautsContainerView.leadingAnchor),
                astronautListVC.view.trailingAnchor.constraint(
                    equalTo: astronautsContainerView.trailingAnchor),
            ])
            astronautListVC.didMove(toParent: self)
        } else {
            astronautListVC?.update(with: astronauts)
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US")
            return displayFormatter.string(from: date)
        }
        return "Date TBD"
    }

    private func statusColor(for statusName: String) -> UIColor {
        switch statusName.lowercased() {
        case "success", "go": return .systemGreen
        case "failure": return .systemRed
        case "in flight": return .systemIndigo
        default: return .systemOrange
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                self?.viewModel.fetchLaunchDetail()
            })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(launchImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(mainStackView)

        actionButtonsStack.addArrangedSubview(favoriteButton)
        actionButtonsStack.addArrangedSubview(notificationButton)

        let padding: CGFloat = 16.0

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            launchImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            launchImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: padding),
            launchImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -padding),
            launchImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),

            statusLabel.topAnchor.constraint(equalTo: launchImageView.topAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(
                equalTo: launchImageView.trailingAnchor, constant: -8),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 28),

            mainStackView.topAnchor.constraint(
                equalTo: launchImageView.bottomAnchor, constant: padding),
            mainStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: padding),
            mainStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -padding),
            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -padding),

            astronautsContainerView.heightAnchor.constraint(equalToConstant: 150),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }
}
