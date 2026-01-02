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

        static let noData = Configuration(
            image: UIImage(systemName: "tray"),
            title: "No Data",
            message: "There's nothing to show here yet.",
            actionTitle: nil,
            action: nil
        )

        static let noInternet = Configuration(
            image: UIImage(systemName: "wifi.slash"),
            title: "No Internet Connection",
            message: "Please check your connection and try again.",
            actionTitle: "Try Again",
            action: nil
        )

        static let noFavorites = Configuration(
            image: UIImage(systemName: "star"),
            title: "No Favorites",
            message: "Add launches to your favorites to see them here.",
            actionTitle: "Browse Launches",
            action: nil
        )

        static let noSearchResults = Configuration(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No Results",
            message: "Try adjusting your search or filters.",
            actionTitle: nil,
            action: nil
        )

        static let error = Configuration(
            image: UIImage(systemName: "exclamationmark.triangle"),
            title: "Something Went Wrong",
            message: "An error occurred. Please try again.",
            actionTitle: "Retry",
            action: nil
        )
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
