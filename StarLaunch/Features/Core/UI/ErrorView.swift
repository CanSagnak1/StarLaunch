//
//  ErrorView.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import UIKit

final class ErrorView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Colors.subtitleColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Retry"
        config.image = UIImage(systemName: "arrow.clockwise")
        config.imagePadding = 6
        config.baseForegroundColor = .systemBlue

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = Colors.subtitleColor
        button.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return button
    }()

    var retryHandler: (() -> Void)?
    var dismissHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(retryButton)
        containerView.addSubview(dismissButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconImageView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            dismissButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            dismissButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -12),
            dismissButton.widthAnchor.constraint(equalToConstant: 24),
            dismissButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(
                equalTo: dismissButton.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),

            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            retryButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            retryButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ])
    }

    func configure(title: String, message: String, showRetry: Bool = true) {
        titleLabel.text = title
        messageLabel.text = message
        retryButton.isHidden = !showRetry
    }

    func configure(with error: NetworkError) {
        titleLabel.text = "Connection Error"
        messageLabel.text = error.userFriendlyMessage
        retryButton.isHidden = !error.isRetryable
    }

    @objc private func retryTapped() {
        retryHandler?()
    }

    @objc private func dismissTapped() {
        dismissHandler?()
        hide()
    }

    func show(in view: UIView, at position: Position = .top, animated: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        switch position {
        case .top:
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
                .isActive = true
        case .bottom:
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
                .isActive = true
        }

        if animated {
            alpha = 0
            transform = CGAffineTransform(translationX: 0, y: position == .top ? -50 : 50)
            UIView.animate(
                withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5
            ) {
                self.alpha = 1
                self.transform = .identity
            }
        }
    }

    func hide(animated: Bool = true) {
        if animated {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.alpha = 0
                }
            ) { _ in
                self.removeFromSuperview()
            }
        } else {
            removeFromSuperview()
        }
    }

    enum Position {
        case top
        case bottom
    }
}

final class NetworkStatusBanner: UIView {
    static let shared = NetworkStatusBanner()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private var isShowing = false

    private init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemRed

        let stackView = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    func showOffline(in window: UIWindow) {
        guard !isShowing else { return }
        isShowing = true

        iconImageView.image = UIImage(systemName: "wifi.slash")
        messageLabel.text = "No Internet Connection"
        backgroundColor = .systemRed

        show(in: window)
    }

    func showOnline(in window: UIWindow) {
        guard isShowing else { return }

        iconImageView.image = UIImage(systemName: "wifi")
        messageLabel.text = "Back Online"
        backgroundColor = .systemGreen

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.hide()
        }
    }

    private func show(in window: UIWindow) {
        translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: window.leadingAnchor),
            trailingAnchor.constraint(equalTo: window.trailingAnchor),
            heightAnchor.constraint(equalToConstant: 32),
        ])

        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -32)

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    private func hide() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: -32)
            }
        ) { _ in
            self.isShowing = false
            self.removeFromSuperview()
        }
    }
}
