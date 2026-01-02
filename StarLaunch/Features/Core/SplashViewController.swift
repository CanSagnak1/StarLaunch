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

    private let viewModel = DashboardViewModel()
    private var cancellables = Set<AnyCancellable>()

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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.titleColor
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.text = ""
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.subtitleColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Loading space data..."
        label.alpha = 0
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = Colors.titleColor
        indicator.hidesWhenStopped = true
        return indicator
    }()

    deinit {
        typingTimer?.invalidate()
        typingTimer = nil
        cancellables.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTypingAnimation()

        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.subtitleLabel.alpha = 1
        }

        activityIndicator.startAnimating()
        viewModel.fetchStarshipData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        typingTimer?.invalidate()
        typingTimer = nil
    }

    private func bindViewModel() {
        viewModel.$programInfo
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] _ in
                self?.navigateToDashboard()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleError(message: message)
            }
            .store(in: &cancellables)

        viewModel.$isOfflineMode
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] _ in
                self?.navigateToDashboard()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .dropFirst()
            .filter { !$0 }
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.programInfo != nil || self.viewModel.isOfflineMode {
                    self.navigateToDashboard()
                }
            }
            .store(in: &cancellables)

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.view.window?.rootViewController === self else { return }
            self.navigateToDashboard()
        }
    }

    private func navigateToDashboard() {
        typingTimer?.invalidate()
        typingTimer = nil
        activityIndicator.stopAnimating()

        guard let window = view.window else {
            return
        }


        let navigationController = UINavigationController()
        let coordinator = MainCoordinator(navigationController: navigationController)

        let dashboardVC = DashboardViewController(
            viewModel: self.viewModel, coordinator: coordinator)
        navigationController.setViewControllers([dashboardVC], animated: false)

        if let sceneDelegate = window.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.coordinator = coordinator
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
        }
    }

    private func navigateWithoutCoordinator() {
        navigateToDashboard()
    }

    private func handleError(message: String) {
        activityIndicator.stopAnimating()
        subtitleLabel.text = "Connection error"
        subtitleLabel.textColor = .systemOrange

        if viewModel.isOfflineMode {
            navigateToDashboard()
        } else {
            showErrorAlert(message: message)
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "Retry", style: .default,
                handler: { [weak self] _ in
                    self?.subtitleLabel.text = "Loading space data..."
                    self?.subtitleLabel.textColor = Colors.subtitleColor
                    self?.activityIndicator.startAnimating()
                    self?.viewModel.refreshData()
                }))

        if OfflineDataManager.shared.hasOfflineData {
            alert.addAction(
                UIAlertAction(
                    title: "Use Offline Data", style: .default,
                    handler: { [weak self] _ in
                        self?.navigateToDashboard()
                    }))
        }

        present(alert, animated: true)
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor, constant: 16),
        ])
    }

    private func startTypingAnimation() {
        typingTimer?.invalidate()
        titleLabel.text = ""
        currentCharacterIndex = 0

        typingTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
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
        } else {
            typingTimer?.invalidate()
            typingTimer = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard self?.typingTimer == nil else { return }
                self?.startTypingAnimation()
            }
        }
    }
}
