//
//  DashboardViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import UIKit

final class DashboardViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: DashboardViewModel
    private weak var coordinator: MainCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var agencyLogos: [UIImage] = []
    private var starshipImages: [UIImage] = []
    private var currentStarshipIndex = 0
    private var starshipAnimationTimer: Timer?

    // MARK: - UI Components

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
        imageView.image = UIImage(named: "background_1")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.3
        return imageView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isHidden = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()

    // MARK: - Hero Section

    private let heroContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = Colors.cardBackground
        return imageView
    }()

    private let heroGradientOverlay: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor,
        ]
        layer.locations = [0.4, 1.0]
        return layer
    }()

    private let heroGlowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.accentPurple
        view.alpha = 0.3
        view.layer.cornerRadius = 100
        return view
    }()

    private let programTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let programSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.accentCyan
        label.text = "SPACE EXPLORATION PROGRAM"
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = Colors.subtitleColor
        label.numberOfLines = 4
        return label
    }()

    // MARK: - Stats Section

    private let statsHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "MISSION STATISTICS"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = Colors.tertiaryColor
        label.textAlignment = .left
        return label
    }()

    private lazy var totalLaunchCard = StatCardView(
        symbolName: "flame.fill",
        title: "TOTAL LAUNCHES",
        accentColor: Colors.accentOrange
    )

    private lazy var successRateCard = StatCardView(
        symbolName: "checkmark.seal.fill",
        title: "SUCCESS RATE",
        accentColor: Colors.success
    )

    // MARK: - Quick Actions Section

    private let quickActionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "QUICK ACTIONS"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = Colors.tertiaryColor
        return label
    }()

    private lazy var launchesActionCard = createActionCard(
        title: "Upcoming Launches",
        subtitle: "See launch schedule",
        iconName: "calendar.badge.clock",
        gradient: Colors.blueGradient
    )

    private lazy var favoritesActionCard = createActionCard(
        title: "My Favorites",
        subtitle: "Saved launches",
        iconName: "star.fill",
        gradient: Colors.purpleGradient
    )

    private lazy var searchActionCard = createActionCard(
        title: "Search",
        subtitle: "Find launches",
        iconName: "magnifyingglass",
        gradient: [Colors.accentCyan.cgColor, Colors.accentBlue.cgColor]
    )

    // MARK: - Agencies Section

    private let agenciesHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "PARTNER AGENCIES"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = Colors.tertiaryColor
        return label
    }()

    private var agenciesCollectionView: UICollectionView!

    // MARK: - SpaceX Button

    private lazy var spaceXButton: UIButton = {
        let button = GradientButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  Visit SpaceX Website", for: .normal)
        button.setImage(UIImage(systemName: "safari.fill"), for: .normal)
        button.tintColor = .white
        button.gradientColors = Colors.primaryGradient
        button.addTarget(self, action: #selector(openSpaceXPage), for: .touchUpInside)
        return button
    }()

    // MARK: - Offline Banner

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
        label.text = "Offline Mode - Using cached data"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    private let errorView = ErrorView()

    // MARK: - Init

    init(viewModel: DashboardViewModel, coordinator: MainCoordinator? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        starshipAnimationTimer?.invalidate()
        starshipAnimationTimer = nil
        cancellables.removeAll()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()

        if viewModel.isLoading {
            activityIndicator.startAnimating()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
        heroGradientOverlay.frame = heroImageView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        if !starshipImages.isEmpty && starshipAnimationTimer == nil {
            startStarshipAnimation()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        starshipAnimationTimer?.invalidate()
        starshipAnimationTimer = nil
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.$programInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] program in
                guard let self, let program else { return }
                self.programTitleLabel.text = program.name
                self.descriptionLabel.text = program.description
                self.handleLoadingState(isFinished: true)
            }
            .store(in: &cancellables)

        viewModel.$launchCount
            .map { "\($0)" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.totalLaunchCard.updateValue(count)
            }
            .store(in: &cancellables)

        viewModel.$successRate
            .map { "\($0)%" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.successRateCard.updateValue(rate)
            }
            .store(in: &cancellables)

        viewModel.$agencies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] agencies in
                guard let self = self, !agencies.isEmpty else { return }
                self.fetchAgencyLogos(from: agencies)
            }
            .store(in: &cancellables)

        viewModel.$starshipVehicles
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] vehicles in
                self?.fetchStarshipImages(from: vehicles)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showErrorView(message: message)
            }
            .store(in: &cancellables)

        viewModel.$isOfflineMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOffline in
                self?.offlineBanner.isHidden = !isOffline
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func openSpaceXPage() {
        HapticManager.shared.buttonTap()
        guard let urlString = viewModel.programInfo?.infoUrl, let url = URL(string: urlString)
        else {
            HapticManager.shared.error()
            showAlert(with: "Invalid URL", message: "SpaceX page could not be opened.")
            return
        }
        UIApplication.shared.open(url)
    }

    @objc private func navigateToLaunchList() {
        HapticManager.shared.navigation()
        if let coordinator = coordinator {
            coordinator.showLaunchList()
        } else {
            let viewModel = LaunchListViewModel()
            let launchListVC = LaunchListViewController(viewModel: viewModel, coordinator: nil)
            navigationController?.pushViewController(launchListVC, animated: true)
        }
    }

    @objc private func navigateToFavorites() {
        HapticManager.shared.navigation()
        coordinator?.showFavorites()
    }

    @objc private func navigateToSearch() {
        HapticManager.shared.navigation()
        coordinator?.showSearch()
    }

    // MARK: - State Handling

    private func handleLoadingState(isFinished: Bool, error: String? = nil) {
        activityIndicator.stopAnimating()
        if isFinished {
            scrollView.isHidden = false
            animateContentAppearance()
            if !starshipImages.isEmpty {
                startStarshipAnimation()
            }
        }
        if let error {
            showAlert(with: "Error", message: error)
        }
    }

    private func animateContentAppearance() {
        mainStackView.alpha = 0
        mainStackView.transform = CGAffineTransform(translationX: 0, y: 30)

        UIView.animate(
            withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0
        ) {
            self.mainStackView.alpha = 1
            self.mainStackView.transform = .identity
        }
    }

    private func showErrorView(message: String) {
        activityIndicator.stopAnimating()

        errorView.configure(title: "Connection Error", message: message)
        errorView.retryHandler = { [weak self] in
            self?.errorView.hide()
            self?.activityIndicator.startAnimating()
            self?.viewModel.refreshData()
        }
        errorView.show(in: view, at: .bottom)
    }

    // MARK: - Image Loading

    private func fetchAgencyLogos(from agencies: [Agency]) {
        Task {
            let logos = await withTaskGroup(of: UIImage?.self, returning: [UIImage].self) { group in
                for agency in agencies {
                    if let urlString = agency.logoUrl, let url = URL(string: urlString) {
                        group.addTask { await ImageLoader.shared.loadImage(from: url) }
                    }
                }
                var collected: [UIImage] = []
                for await image in group {
                    if let image = image { collected.append(image) }
                }
                return collected
            }
            self.agencyLogos = logos
            self.agenciesCollectionView.reloadData()
        }
    }

    private func fetchStarshipImages(from vehicles: [Spacecraft]) {
        Task {
            let images = await withTaskGroup(of: UIImage?.self, returning: [UIImage].self) {
                group in
                for vehicle in vehicles {
                    if let urlString = vehicle.imageUrl, let url = URL(string: urlString) {
                        group.addTask { await ImageLoader.shared.loadImage(from: url) }
                    }
                }
                var collected: [UIImage] = []
                for await image in group {
                    if let image = image { collected.append(image) }
                }
                return collected
            }
            self.starshipImages = images
            if !self.scrollView.isHidden {
                self.startStarshipAnimation()
            }
        }
    }

    private func startStarshipAnimation() {
        guard starshipAnimationTimer == nil, !starshipImages.isEmpty else { return }

        heroImageView.image = starshipImages.first

        starshipAnimationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
            [weak self] timer in
            guard let self = self, !self.starshipImages.isEmpty else {
                timer.invalidate()
                return
            }

            self.currentStarshipIndex = (self.currentStarshipIndex + 1) % self.starshipImages.count

            UIView.transition(
                with: self.heroImageView,
                duration: 1.2,
                options: .transitionCrossDissolve,
                animations: {
                    self.heroImageView.image = self.starshipImages[self.currentStarshipIndex]
                }
            )
        }
    }
}

// MARK: - UI Setup

extension DashboardViewController {

    fileprivate func setupNavigationBar() {
        self.title = "StarLaunch"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
    }

    fileprivate func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(scrollView)
        view.addSubview(offlineBanner)
        view.addSubview(activityIndicator)
        scrollView.addSubview(mainStackView)

        setupCollectionView()
        composeMainStackView()
        activateConstraints()

        setupActionCardGestures()
    }

    fileprivate func setupActionCardGestures() {
        let launchesTap = UITapGestureRecognizer(
            target: self, action: #selector(navigateToLaunchList))
        launchesActionCard.addGestureRecognizer(launchesTap)

        let favoritesTap = UITapGestureRecognizer(
            target: self, action: #selector(navigateToFavorites))
        favoritesActionCard.addGestureRecognizer(favoritesTap)

        let searchTap = UITapGestureRecognizer(target: self, action: #selector(navigateToSearch))
        searchActionCard.addGestureRecognizer(searchTap)
    }

    fileprivate func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 50)
        layout.minimumInteritemSpacing = 12
        agenciesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        agenciesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        agenciesCollectionView.backgroundColor = .clear
        agenciesCollectionView.dataSource = self
        agenciesCollectionView.showsHorizontalScrollIndicator = false
        agenciesCollectionView.register(
            AgencyLogoCell.self, forCellWithReuseIdentifier: AgencyLogoCell.reuseID)
    }

    fileprivate func composeMainStackView() {
        mainStackView.addArrangedSubview(createHeroSection())
        mainStackView.addArrangedSubview(createStatsSection())
        mainStackView.addArrangedSubview(createQuickActionsSection())
        mainStackView.addArrangedSubview(createAgenciesSection())
        mainStackView.addArrangedSubview(spaceXButton)

        mainStackView.setCustomSpacing(32, after: createAgenciesSection())

        let bottomSpacer = UIView()
        bottomSpacer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mainStackView.addArrangedSubview(bottomSpacer)
    }

    fileprivate func activateConstraints() {
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

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mainStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            spaceXButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    // MARK: - Section Builders

    fileprivate func createHeroSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(heroGlowView)
        container.addSubview(heroImageView)
        heroImageView.layer.addSublayer(heroGradientOverlay)

        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.addSubview(textContainer)

        textContainer.addSubview(programSubtitleLabel)
        textContainer.addSubview(programTitleLabel)

        container.addSubview(descriptionLabel)

        // Shadow for hero
        heroImageView.layer.shadowColor = Colors.accentPurple.cgColor
        heroImageView.layer.shadowOffset = CGSize(width: 0, height: 8)
        heroImageView.layer.shadowRadius = 24
        heroImageView.layer.shadowOpacity = 0.4
        heroImageView.layer.masksToBounds = false
        heroImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            heroGlowView.centerXAnchor.constraint(equalTo: heroImageView.centerXAnchor),
            heroGlowView.centerYAnchor.constraint(
                equalTo: heroImageView.centerYAnchor, constant: -40),
            heroGlowView.widthAnchor.constraint(equalToConstant: 200),
            heroGlowView.heightAnchor.constraint(equalToConstant: 200),

            heroImageView.topAnchor.constraint(equalTo: container.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            heroImageView.heightAnchor.constraint(
                equalTo: heroImageView.widthAnchor, multiplier: 0.6),

            textContainer.leadingAnchor.constraint(
                equalTo: heroImageView.leadingAnchor, constant: 20),
            textContainer.trailingAnchor.constraint(
                equalTo: heroImageView.trailingAnchor, constant: -20),
            textContainer.bottomAnchor.constraint(
                equalTo: heroImageView.bottomAnchor, constant: -20),

            programSubtitleLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            programSubtitleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),

            programTitleLabel.topAnchor.constraint(
                equalTo: programSubtitleLabel.bottomAnchor, constant: 4),
            programTitleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            programTitleLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            programTitleLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),

            descriptionLabel.topAnchor.constraint(
                equalTo: heroImageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    fileprivate func createStatsSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(statsHeaderLabel)

        let statsStack = UIStackView(arrangedSubviews: [totalLaunchCard, successRateCard])
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 12

        container.addSubview(statsStack)

        NSLayoutConstraint.activate([
            statsHeaderLabel.topAnchor.constraint(equalTo: container.topAnchor),
            statsHeaderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            statsStack.topAnchor.constraint(equalTo: statsHeaderLabel.bottomAnchor, constant: 12),
            statsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            statsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            statsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            statsStack.heightAnchor.constraint(equalToConstant: 130),
        ])

        return container
    }

    fileprivate func createQuickActionsSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(quickActionsLabel)

        let actionsStack = UIStackView(arrangedSubviews: [
            launchesActionCard, favoritesActionCard, searchActionCard,
        ])
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.axis = .horizontal
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 12

        container.addSubview(actionsStack)

        NSLayoutConstraint.activate([
            quickActionsLabel.topAnchor.constraint(equalTo: container.topAnchor),
            quickActionsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            actionsStack.topAnchor.constraint(
                equalTo: quickActionsLabel.bottomAnchor, constant: 12),
            actionsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            actionsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            actionsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            actionsStack.heightAnchor.constraint(equalToConstant: 100),
        ])

        return container
    }

    fileprivate func createAgenciesSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(agenciesHeaderLabel)
        container.addSubview(agenciesCollectionView)

        NSLayoutConstraint.activate([
            agenciesHeaderLabel.topAnchor.constraint(equalTo: container.topAnchor),
            agenciesHeaderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            agenciesCollectionView.topAnchor.constraint(
                equalTo: agenciesHeaderLabel.bottomAnchor, constant: 12),
            agenciesCollectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            agenciesCollectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            agenciesCollectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            agenciesCollectionView.heightAnchor.constraint(equalToConstant: 50),
        ])

        return container
    }

    // MARK: - Component Factory

    fileprivate func createActionCard(
        title: String, subtitle: String, iconName: String, gradient: [CGColor]
    ) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Colors.cardBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = Colors.glassBorder.cgColor
        card.isUserInteractionEnabled = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        gradientLayer.opacity = 0.15
        card.layer.insertSublayer(gradientLayer, at: 0)

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(cgColor: gradient[0]).withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 14

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = UIColor(cgColor: gradient[0])
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = Colors.titleColor
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center

        card.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconContainer.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
        ])

        // Store gradient for later use
        card.tag = 1001
        DispatchQueue.main.async {
            gradientLayer.frame = card.bounds
        }

        return card
    }

    fileprivate func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return agencyLogos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AgencyLogoCell.reuseID,
                for: indexPath
            ) as? AgencyLogoCell
        else {
            fatalError("AgencyLogoCell not found")
        }
        let logo = agencyLogos[indexPath.item]
        cell.configure(with: logo)
        return cell
    }
}
