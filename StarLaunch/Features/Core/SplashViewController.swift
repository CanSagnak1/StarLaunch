//
//  SplashViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import Combine
import UIKit

final class SplashViewController: UIViewController {

    private var typingTimer: Timer?
    private var currentCharacterIndex = 0
    private let fullText = "StarLaunch"

    private var particleEmitter: CAEmitterLayer?
    private var pulseAnimationLayer: CAShapeLayer?

    private let progressContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cardBackground
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()

    private let progressBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let progressGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = Colors.primaryGradient
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = Colors.subtitleColor
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.subtitleColor.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.text = "StarLaunch • created by Can Sağnak"
        label.textAlignment = .center
        return label
    }()

    private var progressWidthConstraint: NSLayoutConstraint?

    private let viewModel = DashboardViewModel()
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
        imageView.alpha = 0.4
        return imageView
    }()

    private let rocketContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let rocketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "paperplane.fill")
        imageView.tintColor = Colors.accentCyan
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        return imageView
    }()

    private let glowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.accentCyan.withAlphaComponent(0.3)
        view.layer.cornerRadius = 60
        view.alpha = 0
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.text = L10n.splashTitle
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.accentCyan
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = L10n.splashTagline.uppercased()
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: 0, y: 10)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.subtitleColor
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.text = L10n.splashLoading
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        updateLocalizedTexts()

        startAnimations()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.animateProgress()
            self?.viewModel.fetchStarshipData()
        }

        bindViewModel()
    }

    private func updateLocalizedTexts() {
        subtitleLabel.text = L10n.splashLoading
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
        progressGradient.frame = progressBar.bounds
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.handleError(message: message)
            }
            .store(in: &cancellables)

        viewModel.$launchCount
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                if count > 0 {
                    self?.animateProgressComplete()
                }
            }
            .store(in: &cancellables)
    }

    private func startAnimations() {
        UIView.animate(withDuration: 1.0) {
            self.titleLabel.alpha = 1
            self.glowView.alpha = 1
            self.glowView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }

        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseOut) {
            self.taglineLabel.alpha = 1
            self.taglineLabel.transform = .identity
            self.subtitleLabel.alpha = 1
        }

        startTypingAnimation()
    }

    private func animateProgress() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut) {
            self.progressWidthConstraint?.constant = 150  // Partial progress
            self.view.layoutIfNeeded()
        }
    }

    private func animateProgressComplete() {
        self.view.layoutIfNeeded()
        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressBar.widthAnchor.constraint(
            equalTo: progressContainer.widthAnchor)
        progressWidthConstraint?.isActive = true

        subtitleLabel.text = L10n.splashReady
        subtitleLabel.textColor = Colors.success

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            HapticManager.shared.success()
            self.animateExitAndNavigate()
        }
    }

    private func animateExitAndNavigate() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.rocketImageView.transform = CGAffineTransform(translationX: 0, y: -1000)
                self.titleLabel.alpha = 0
                self.taglineLabel.alpha = 0
                self.subtitleLabel.alpha = 0
                self.progressContainer.alpha = 0
                self.versionLabel.alpha = 0
            }
        ) { _ in
            self.navigateToDashboard()
        }
    }

    private func navigateToDashboard() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }

        if OnboardingManager.shared.shouldShowOnboarding {
            let onboardingVC = OnboardingViewController()
            onboardingVC.onComplete = {
                sceneDelegate.setupMainApp()
            }
            onboardingVC.modalPresentationStyle = .fullScreen

            if let window = sceneDelegate.window {
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
                    window.rootViewController = onboardingVC
                }
            }
        } else {
            sceneDelegate.setupMainApp()
        }
    }

    private func handleError(message: String) {
        activityIndicator.stopAnimating()
        subtitleLabel.text = L10n.error
        subtitleLabel.textColor = Colors.warning

        if viewModel.isOfflineMode {
            animateProgressComplete()
        } else {
            showErrorAlert(message: message)
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: L10n.error, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: L10n.retry, style: .default,
                handler: { [weak self] _ in
                    self?.subtitleLabel.text = L10n.splashLoading
                    self?.subtitleLabel.textColor = Colors.subtitleColor
                    self?.activityIndicator.startAnimating()
                    self?.animateProgress()
                    self?.viewModel.refreshData()
                }))

        if OfflineDataManager.shared.hasOfflineData {
            alert.addAction(
                UIAlertAction(
                    title: L10n.launchesOfflineMode, style: .default,
                    handler: { [weak self] _ in
                        self?.animateProgressComplete()
                    }))
        }

        present(alert, animated: true)
    }

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(glowView)
        view.addSubview(rocketContainer)
        rocketContainer.addSubview(rocketImageView)
        view.addSubview(titleLabel)
        view.addSubview(taglineLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(progressContainer)
        progressContainer.addSubview(progressBar)
        progressBar.layer.addSublayer(progressGradient)
        view.addSubview(versionLabel)

        progressWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            rocketContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rocketContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            rocketContainer.widthAnchor.constraint(equalToConstant: 80),
            rocketContainer.heightAnchor.constraint(equalToConstant: 80),

            rocketImageView.centerXAnchor.constraint(equalTo: rocketContainer.centerXAnchor),
            rocketImageView.centerYAnchor.constraint(equalTo: rocketContainer.centerYAnchor),
            rocketImageView.widthAnchor.constraint(equalToConstant: 60),
            rocketImageView.heightAnchor.constraint(equalToConstant: 60),

            glowView.centerXAnchor.constraint(equalTo: rocketContainer.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: rocketContainer.centerYAnchor),
            glowView.widthAnchor.constraint(equalToConstant: 120),
            glowView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: rocketContainer.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 40),

            progressContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainer.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor, constant: 16),
            progressContainer.widthAnchor.constraint(equalToConstant: 200),
            progressContainer.heightAnchor.constraint(equalToConstant: 6),

            progressBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor),
            progressWidthConstraint!,

            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func startTypingAnimation() {
        typingTimer?.invalidate()
        titleLabel.text = ""
        currentCharacterIndex = 0

        typingTimer = Timer.scheduledTimer(
            timeInterval: 0.08,
            target: self,
            selector: #selector(typeNextCharacter),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func typeNextCharacter() {
        if currentCharacterIndex < fullText.count {
            let index = fullText.index(fullText.startIndex, offsetBy: currentCharacterIndex)
            titleLabel.text?.append(fullText[index])
            currentCharacterIndex += 1

            if currentCharacterIndex % 3 == 0 {
                HapticManager.shared.lightTap()
            }
        } else {
            typingTimer?.invalidate()
            typingTimer = nil
        }
    }
}
