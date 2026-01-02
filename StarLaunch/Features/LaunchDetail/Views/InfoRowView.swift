//
//  InfoRowView.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import UIKit

final class InfoRowView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.glassBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Colors.glassBorder.cgColor
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.accentBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 10
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.accentBlue
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Colors.subtitleColor
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()

    private var accentColor: UIColor = Colors.accentBlue

    init(
        iconSystemName: String, title: String, value: String,
        accentColor: UIColor = Colors.accentBlue
    ) {
        super.init(frame: .zero)
        self.accentColor = accentColor

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        self.iconImageView.image = UIImage(systemName: iconSystemName, withConfiguration: config)
        self.iconImageView.tintColor = accentColor
        self.iconContainerView.backgroundColor = accentColor.withAlphaComponent(0.1)
        self.titleLabel.text = title
        self.valueLabel.text = value
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .horizontal
        textStack.spacing = 12
        textStack.alignment = .center

        containerView.addSubview(textStack)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconContainerView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 12),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 36),
            iconContainerView.heightAnchor.constraint(equalToConstant: 36),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),

            textStack.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -14),
            textStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
        ])

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        setupTapGesture()
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        HapticManager.shared.softTap()

        UIView.animate(
            withDuration: 0.08,
            animations: {
                self.containerView.backgroundColor = Colors.glassHighlight
                self.iconContainerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        ) { _ in
            UIView.animate(withDuration: 0.15) {
                self.containerView.backgroundColor = Colors.glassBackground
                self.iconContainerView.transform = .identity
            }
        }
    }

    public func updateValue(_ newValue: String) {
        UIView.transition(with: valueLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.valueLabel.text = newValue
        }
    }

    public func highlightValue(color: UIColor = Colors.success) {
        valueLabel.textColor = color
    }
}
