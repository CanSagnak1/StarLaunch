//
//  OnboardingViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import UIKit

final class OnboardingViewController: UIViewController {

    // MARK: - Properties
    var onComplete: (() -> Void)?

    private var currentPage = 0
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "paperplane.fill",
            iconColor: Colors.accentCyan,
            title: L10n.onboardingWelcomeTitle,
            description: L10n.onboardingWelcomeDesc
        ),
        OnboardingPage(
            icon: "clock.badge.checkmark.fill",
            iconColor: Colors.accentBlue,
            title: L10n.onboardingCountdownTitle,
            description: L10n.onboardingCountdownDesc
        ),
        OnboardingPage(
            icon: "star.fill",
            iconColor: Colors.warning,
            title: L10n.onboardingFavoritesTitle,
            description: L10n.onboardingFavoritesDesc
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            iconColor: Colors.accentPurple,
            title: L10n.onboardingNotificationsTitle,
            description: L10n.onboardingNotificationsDesc
        ),
        OnboardingPage(
            icon: "wifi.slash",
            iconColor: Colors.success,
            title: L10n.onboardingOfflineTitle,
            description: L10n.onboardingOfflineDesc
        ),
    ]

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
        imageView.alpha = 0.4
        return imageView
    }()

    private lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = pages.count
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = Colors.accentCyan
        pc.pageIndicatorTintColor = Colors.subtitleColor.withAlphaComponent(0.3)
        return pc
    }()

    // ... (lines 54-79)

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(L10n.onboardingSkip, for: .normal)
        button.setTitleColor(Colors.tertiaryColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        return button
    }()

    // ... (lines 87-108)

    private lazy var nextButton: GradientButton = {
        let button = GradientButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(L10n.onboardingNext, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.gradientColors = Colors.primaryGradient
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageViewController()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupUI() {
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        view.addSubview(nextButton)

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            skipButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            pageViewController.view.topAnchor.constraint(
                equalTo: skipButton.bottomAnchor, constant: 20),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(
                equalTo: pageControl.topAnchor, constant: -20),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    private func setupPageViewController() {
        if let firstPage = createPageContentViewController(at: 0) {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
        }
    }

    private func createPageContentViewController(at index: Int)
        -> OnboardingPageContentViewController?
    {
        guard index >= 0 && index < pages.count else { return nil }
        let page = pages[index]
        let vc = OnboardingPageContentViewController(page: page, index: index)
        return vc
    }

    // MARK: - Actions
    @objc private func skipTapped() {
        HapticManager.shared.buttonTap()
        completeOnboarding()
    }

    @objc private func nextTapped() {
        HapticManager.shared.buttonTap()

        if currentPage == pages.count - 1 {
            completeOnboarding()
        } else {
            goToPage(currentPage + 1)
        }
    }

    @objc private func pageControlTapped(_ sender: UIPageControl) {
        goToPage(sender.currentPage)
    }

    private func goToPage(_ index: Int) {
        guard let vc = createPageContentViewController(at: index) else { return }

        let direction: UIPageViewController.NavigationDirection =
            index > currentPage ? .forward : .reverse
        pageViewController.setViewControllers([vc], direction: direction, animated: true)
        currentPage = index
        updateUI()
    }

    private func updateUI() {
        pageControl.currentPage = currentPage

        let isLastPage = currentPage == pages.count - 1

        UIView.animate(withDuration: 0.3) {
            self.nextButton.setTitle(
                isLastPage ? L10n.onboardingGetStarted : L10n.onboardingNext, for: .normal)
            self.skipButton.alpha = isLastPage ? 0 : 1
        }
    }

    private func completeOnboarding() {
        OnboardingManager.shared.markOnboardingComplete()

        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.view.alpha = 0
            }
        ) { _ in
            self.onComplete?()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let contentVC = viewController as? OnboardingPageContentViewController else {
            return nil
        }
        return createPageContentViewController(at: contentVC.pageIndex - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let contentVC = viewController as? OnboardingPageContentViewController else {
            return nil
        }
        return createPageContentViewController(at: contentVC.pageIndex + 1)
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
            let contentVC = pageViewController.viewControllers?.first
                as? OnboardingPageContentViewController
        else { return }

        currentPage = contentVC.pageIndex
        updateUI()
    }
}

// MARK: - OnboardingPage Model
struct OnboardingPage {
    let icon: String
    let iconColor: UIColor
    let title: String
    let description: String
}

// MARK: - OnboardingPageContentViewController
final class OnboardingPageContentViewController: UIViewController {

    let pageIndex: Int
    private let page: OnboardingPage

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 60
        view.backgroundColor = Colors.cardBackground.withAlphaComponent(0.6)
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = Colors.titleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = Colors.subtitleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(page: OnboardingPage, index: Int) {
        self.page = page
        self.pageIndex = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        iconContainerView.addSubview(iconImageView)
        view.addSubview(iconContainerView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            iconContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            iconContainerView.widthAnchor.constraint(equalToConstant: 120),
            iconContainerView.heightAnchor.constraint(equalToConstant: 120),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }

    private func configureContent() {
        iconImageView.image = UIImage(systemName: page.icon)
        iconImageView.tintColor = page.iconColor
        titleLabel.text = page.title
        descriptionLabel.text = page.description

        // Add subtle glow to icon container
        iconContainerView.layer.shadowColor = page.iconColor.cgColor
        iconContainerView.layer.shadowOffset = .zero
        iconContainerView.layer.shadowRadius = 20
        iconContainerView.layer.shadowOpacity = 0.3
    }

    private func animateIn() {
        iconContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        iconContainerView.alpha = 0
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        descriptionLabel.alpha = 0
        descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 20)

        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            self.iconContainerView.transform = .identity
            self.iconContainerView.alpha = 1
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.15,
            options: [.curveEaseOut]
        ) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [.curveEaseOut]
        ) {
            self.descriptionLabel.alpha = 1
            self.descriptionLabel.transform = .identity
        }
    }
}
