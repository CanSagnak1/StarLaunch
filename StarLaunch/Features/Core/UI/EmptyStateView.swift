//
//  EmptyStateView.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import UIKit

final class EmptyStateView: UIView {

    struct Configuration {
        let image: UIImage?
        let title: String
        let message: String
        let actionTitle: String?
        let action: (() -> Void)?

        static var noData: Configuration {
            Configuration(
                image: UIImage(systemName: "tray"),
                title: L10n.emptyNoDataTitle,
                message: L10n.emptyNoDataMessage,
                actionTitle: nil,
                action: nil
            )
        }

        static var noInternet: Configuration {
            Configuration(
                image: UIImage(systemName: "wifi.slash"),
                title: L10n.emptyNoInternetTitle,
                message: L10n.errorNoInternet,
                actionTitle: L10n.retry,
                action: nil
            )
        }

        static var noFavorites: Configuration {
            Configuration(
                image: UIImage(systemName: "star"),
                title: L10n.favoritesEmptyTitle,
                message: L10n.favoritesEmptyMessage,
                actionTitle: L10n.favoritesBrowse,
                action: nil
            )
        }

        static var noSearchResults: Configuration {
            Configuration(
                image: UIImage(systemName: "magnifyingglass"),
                title: L10n.emptyNoSearchResultsTitle,
                message: L10n.emptyNoSearchResultsMessage,
                actionTitle: nil,
                action: nil
            )
        }

        static var error: Configuration {
            Configuration(
                image: UIImage(systemName: "exclamationmark.triangle"),
                title: L10n.emptyErrorTitle,
                message: L10n.errorGeneric,
                actionTitle: L10n.retry,
                action: nil
            )
        }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.subtitleColor
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Colors.titleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = Colors.subtitleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = Colors.buttonBackground
        config.baseForegroundColor = Colors.titleColor
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 24, bottom: 12, trailing: 24)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()

    private var actionHandler: (() -> Void)?
    private(set) var currentConfiguration: Configuration?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        let stackView = UIStackView(arrangedSubviews: [
            imageView, titleLabel, messageLabel, actionButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.setCustomSpacing(24, after: messageLabel)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),

            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    func configure(with config: Configuration) {
        self.currentConfiguration = config
        imageView.image = config.image
        titleLabel.text = config.title
        messageLabel.text = config.message

        if let actionTitle = config.actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
            actionHandler = config.action
        } else {
            actionButton.isHidden = true
            actionHandler = nil
        }
    }

    func setAction(_ action: @escaping () -> Void) {
        actionHandler = action
    }

    @objc private func actionTapped() {
        actionHandler?()
    }

    func show(in view: UIView, animated: Bool = true) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        if animated {
            self.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }

    func hide(animated: Bool = true) {
        if animated {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.alpha = 0
                }
            ) { _ in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
}
