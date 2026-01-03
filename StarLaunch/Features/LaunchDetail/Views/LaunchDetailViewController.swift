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

    private lazy var favoriteBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        button.tintColor = Colors.titleColor
        return button
    }()

    private lazy var shareBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareLaunch)
        )
        button.tintColor = Colors.titleColor
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
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
        viewModel.fetchLaunchDetail()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshForLanguageChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
        refreshForLanguageChange()
    }

    @objc private func refreshForLanguageChange() {
        title = L10n.detailTitle
        crewTitleLabel.text = L10n.detailCrew

        if let detail = viewModel.launchDetail {
            updateUIWith(detail)
        }
    }

    @objc private func toggleFavorite() {
        HapticManager.shared.buttonTap()
        viewModel.toggleFavorite()
        updateFavoriteButton(isFavorite: viewModel.isFavorite)
    }

    @objc private func toggleNotification() {
        HapticManager.shared.buttonTap()
        viewModel.toggleNotification()
        updateNotificationButton(isScheduled: viewModel.isNotificationScheduled)
    }

    @objc private func shareLaunch() {
        HapticManager.shared.buttonTap()
        guard let detail = viewModel.launchDetail else { return }
        let shareText = "\(L10n.shareText)\n\(detail.name)\n\(detail.net)"
        let activityVC = UIActivityViewController(
            activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        favoriteBarButton.image = UIImage(systemName: isFavorite ? "star.fill" : "star")
        favoriteBarButton.tintColor = isFavorite ? Colors.warning : Colors.titleColor
    }


    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive launch reminders.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: L10n.settingsTitle, style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        present(alert, animated: true)
    }


    private func updateNotificationButton(isScheduled: Bool) {
        var config = notificationButton.configuration
        config?.image = UIImage(systemName: isScheduled ? "bell.fill" : "bell")
        config?.title = isScheduled ? L10n.detailReminderSet : L10n.detailRemindMe
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

        let originalDescription = launchDetail.mission?.description ?? L10n.detailNoMission
        let originalStatus = launchDetail.status.name
        let originalRocket = launchDetail.rocket.configuration.fullName
        let originalLocation = "\(launchDetail.pad.name), \(launchDetail.pad.location.name)"
        let originalProvider = launchDetail.launchServiceProvider.name

        missionDescriptionLabel.text = originalDescription
        rocketInfoView.updateValue(originalRocket)
        launchPadInfoView.updateValue(originalLocation)
        serviceProviderInfoView.updateValue(originalProvider)

        if LocalizationManager.shared.currentLanguage != .english {
            Task {
                let langCode = LocalizationManager.shared.currentLanguage.code

                async let translatedDesc = TranslationService.shared.translate(
                    originalDescription, to: langCode)
                async let translatedStatus = TranslationService.shared.translate(
                    originalStatus, to: langCode)
                async let translatedRocket = TranslationService.shared.translate(
                    originalRocket, to: langCode)
                async let translatedLocation = TranslationService.shared.translate(
                    originalLocation, to: langCode)
                async let translatedProvider = TranslationService.shared.translate(
                    originalProvider, to: langCode)

                let results = await (
                    translatedDesc, translatedStatus, translatedRocket, translatedLocation,
                    translatedProvider
                )

                await MainActor.run {
                    self.missionDescriptionLabel.text = results.0
                    self.statusLabel.text = results.1.uppercased()
                    self.rocketInfoView.updateValue(results.2)
                    self.launchPadInfoView.updateValue(results.3)
                    self.serviceProviderInfoView.updateValue(results.4)
                }
            }
        }

        rocketInfoView.updateTitle(L10n.detailRocket)
        launchPadInfoView.updateTitle(L10n.detailLocation)
        serviceProviderInfoView.updateTitle(L10n.detailProvider)

        if let imageUrlString = launchDetail.image, let url = URL(string: imageUrlString) {
            Task {
                launchImageView.image = await ImageLoader.shared.loadImage(from: url)
            }
        }

        let astronauts = launchDetail.program.first?.crew?.map { $0.astronaut } ?? []
        if !astronauts.isEmpty {
            crewTitleLabel.isHidden = false
            crewTitleLabel.text = L10n.detailCrew
            astronautsContainerView.isHidden = false
            updateAstronauts(with: astronauts)
        } else {
            crewTitleLabel.isHidden = true
            astronautsContainerView.isHidden = true
        }
    }


    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            let identifier =
                LocalizationManager.shared.currentLanguage == .turkish ? "tr_TR" : "en_US"
            displayFormatter.locale = Locale(identifier: identifier)
            return displayFormatter.string(from: date)
        }
        return L10n.detailTbd
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

    private func setupNavigationBar() {
        title = L10n.detailTitle
        navigationController?.navigationBar.tintColor = Colors.accentBlue
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [shareBarButton, favoriteBarButton]
    }

    private func bindViewModel() {
        viewModel.$launchDetail
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] detail in
                self?.updateUIWith(detail)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
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
    }

    private func updateAstronauts(with astronauts: [Astronaut]) {
        if astronautListVC == nil {
            astronautListVC = AstronautListViewController(astronauts: astronauts)
            if let vc = astronautListVC {
                addChild(vc)
                astronautsContainerView.addSubview(vc.view)
                vc.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    vc.view.topAnchor.constraint(equalTo: astronautsContainerView.topAnchor),
                    vc.view.leadingAnchor.constraint(
                        equalTo: astronautsContainerView.leadingAnchor),
                    vc.view.trailingAnchor.constraint(
                        equalTo: astronautsContainerView.trailingAnchor),
                    vc.view.bottomAnchor.constraint(equalTo: astronautsContainerView.bottomAnchor),
                ])
                vc.didMove(toParent: self)
            }
        }
    }
}
