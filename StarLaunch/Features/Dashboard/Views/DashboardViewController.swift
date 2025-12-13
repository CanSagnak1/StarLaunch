//
//  ViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import UIKit
import Combine

final class DashboardViewController: UIViewController {
    
    private let viewModel: DashboardViewModel
    private var cancellables = Set<AnyCancellable>()
    private var agencyLogos: [UIImage] = []
    private var starshipImages: [UIImage] = []
    private var currentStarshipIndex = 0
    private var starshipAnimationTimer: Timer?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background_1")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isHidden = true
        return scrollView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.backgroundColor = Colors.buttonBackground
        return imageView
    }()
    
    private let titleLabel = createLabel(
        font: .systemFont(ofSize: 22, weight: .bold),
        textColor: Colors.titleColor
    )
    
    private let descriptionLabel = createLabel(
        font: .systemFont(ofSize: 15, weight: .regular),
        textColor: Colors.subtitleColor
    )
    
    private lazy var totalLaunchCard = StatCardView(
        symbolName: "",
        title: "TOTAL LAUNCHES"
    )
    
    private lazy var successRateCard = StatCardView(
        symbolName: "",
        title: "SUCCESS RATE"
    )
    
    private let agenciesLabel = createLabel(
        text: "",
        font: .systemFont(ofSize: 12, weight: .semibold),
        textColor: Colors.subtitleColor
    )
    
    private var agenciesCollectionView: UICollectionView!
    
    private lazy var spaceXButton = createButton(
        title: "Go To SpaceX Page",
        symbolName: "safari.fill"
    )
    
    private lazy var launchesButton = createButton(
        title: "See Upcoming Launches",
        symbolName: "calendar.badge.clock"
    )
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = Colors.titleColor
        return indicator
    }()
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        if viewModel.isLoading {
            activityIndicator.startAnimating()
        }
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
     
    private func bindViewModel() {
        viewModel.$programInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] program in
                guard let self, let program else { return }
                self.titleLabel.text = program.name
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
                self?.handleLoadingState(isFinished: false, error: message)
            }
            .store(in: &cancellables)
    }
    
    @objc private func openSpaceXPage() {
        guard let urlString = viewModel.programInfo?.infoUrl, let url = URL(string: urlString) else {
            showAlert(with: "Invalid URL", message: "SpaceX sayfası açılamadı.")
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc private func navigateToLaunchList() {
        let launchListVC = LaunchListViewController()
        navigationController?.pushViewController(launchListVC, animated: true)
    }
    
    private func handleLoadingState(isFinished: Bool, error: String? = nil) {
        activityIndicator.stopAnimating()
        if isFinished {
            scrollView.isHidden = false
            if !starshipImages.isEmpty {
                startStarshipAnimation()
            }
        }
        if let error {
            showAlert(with: "Hata", message: error)
        }
    }
    
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
            let images = await withTaskGroup(of: UIImage?.self, returning: [UIImage].self) { group in
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
        
        starshipAnimationTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] timer in
            guard let self = self, !self.starshipImages.isEmpty else {
                timer.invalidate()
                return
            }
            
            self.currentStarshipIndex = (self.currentStarshipIndex + 1) % self.starshipImages.count
            
            UIView.transition(
                with: self.heroImageView,
                duration: 1.0,
                options: .transitionCrossDissolve,
                animations: {
                    self.heroImageView.image = self.starshipImages[self.currentStarshipIndex]
                }
            )
        }
    }
}

private extension DashboardViewController {
    
    func setupNavigationBar() {
        self.title = "StarLaunch"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: Colors.titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: Colors.titleColor]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupUI() {
        view.backgroundColor = Colors.appBackground
        
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        scrollView.addSubview(mainStackView)
        
        setupCollectionView()
        composeMainStackView()
        activateConstraints()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 60)
        agenciesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        agenciesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        agenciesCollectionView.backgroundColor = .clear
        agenciesCollectionView.dataSource = self
        agenciesCollectionView.showsHorizontalScrollIndicator = false
        agenciesCollectionView.register(AgencyLogoCell.self, forCellWithReuseIdentifier: AgencyLogoCell.reuseID)
    }
    
    func composeMainStackView() {
        mainStackView.addArrangedSubview(createHeroCard())
        mainStackView.addArrangedSubview(createStatsStack())
        mainStackView.addArrangedSubview(createAgenciesSection())
        mainStackView.addArrangedSubview(createButtonsStack())
        
        if let lastView = mainStackView.arrangedSubviews.last {
            mainStackView.setCustomSpacing(32, after: lastView)
        }
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func createHeroCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = Colors.buttonBackground.withAlphaComponent(0.6)
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true
        
        let contentStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 20, right: 16)
        
        let mainCardStack = UIStackView(arrangedSubviews: [heroImageView, contentStack])
        mainCardStack.axis = .vertical
        mainCardStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(mainCardStack)
        
        NSLayoutConstraint.activate([
            heroImageView.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.56),
            mainCardStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            mainCardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            mainCardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            mainCardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        
        return cardView
    }
    
    func createStatsStack() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [totalLaunchCard, successRateCard])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }
    
    func createAgenciesSection() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [agenciesLabel, agenciesCollectionView])
        stackView.axis = .vertical
        stackView.spacing = 12
        agenciesCollectionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return stackView
    }
    
    func createButtonsStack() -> UIStackView {
        spaceXButton.addTarget(self, action: #selector(openSpaceXPage), for: .touchUpInside)
        launchesButton.addTarget(self, action: #selector(navigateToLaunchList), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [spaceXButton, launchesButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }
    
    static func createLabel(text: String? = nil, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.numberOfLines = 0
        return label
    }
    
    func createButton(title: String, symbolName: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.titleAlignment = .center
        config.image = UIImage(systemName: symbolName)
        config.imagePadding = 8
        config.baseBackgroundColor = Colors.buttonBackground
        config.baseForegroundColor = Colors.titleColor
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 10, bottom: 14, trailing: 10)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return agencyLogos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AgencyLogoCell.reuseID,
            for: indexPath
        ) as? AgencyLogoCell else {
            fatalError("AgencyLogoCell bulunamadı veya cast edilemedi.")
        }
        let logo = agencyLogos[indexPath.item]
        cell.configure(with: logo)
        return cell
    }
}
