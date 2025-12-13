//
//  SplashViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import UIKit
import Combine

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTypingAnimation()
        viewModel.fetchStarshipData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        typingTimer?.invalidate()
    }
    
    private func bindViewModel() {
        viewModel.$programInfo
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigateToDashboard()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func navigateToDashboard() {
        typingTimer?.invalidate()
        let dashboardVC = DashboardViewController(viewModel: self.viewModel)
        let navigationController = UINavigationController(rootViewController: dashboardVC)
        
        guard let window = view.window else { return }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tekrar Dene", style: .default, handler: { [weak self] _ in
            self?.viewModel.fetchStarshipData()
        }))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        view.addSubview(titleLabel)
        
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
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.startTypingAnimation()
            }
        }
    }
}
