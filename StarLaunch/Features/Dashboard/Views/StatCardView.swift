//
//  StatCardView.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import UIKit

final class StatCardView: UIView {

    private let glassCard = GlassCard()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = Colors.accentPurple.withAlphaComponent(0.2)
        return view
    }()

    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.accentPurple
        return imageView
    }()

    private let valueLabel: AnimatedCounterLabel = {
        let label = AnimatedCounterLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = Colors.titleColor
        label.textAlignment = .center
        label.text = "—"
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = Colors.subtitleColor
        label.textAlignment = .center
        return label
    }()

    private var accentColor: UIColor = Colors.accentPurple

    init(symbolName: String, title: String, accentColor: UIColor = Colors.accentPurple) {
        super.init(frame: .zero)
        self.accentColor = accentColor
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        self.symbolImageView.image = UIImage(systemName: symbolName, withConfiguration: config)
        self.symbolImageView.tintColor = accentColor
        self.iconContainerView.backgroundColor = accentColor.withAlphaComponent(0.15)
        self.titleLabel.text = title.uppercased()
        setupCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCard() {
        translatesAutoresizingMaskIntoConstraints = false

        glassCard.translatesAutoresizingMaskIntoConstraints = false
        glassCard.cornerRadius = 20
        addSubview(glassCard)

        iconContainerView.addSubview(symbolImageView)

        let contentStack = UIStackView(arrangedSubviews: [
            iconContainerView, valueLabel, titleLabel,
        ])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 8
        contentStack.setCustomSpacing(12, after: iconContainerView)

        glassCard.addSubview(contentStack)

        NSLayoutConstraint.activate([
            glassCard.topAnchor.constraint(equalTo: topAnchor),
            glassCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassCard.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),

            symbolImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            symbolImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            symbolImageView.widthAnchor.constraint(equalToConstant: 20),
            symbolImageView.heightAnchor.constraint(equalToConstant: 20),

            contentStack.centerXAnchor.constraint(equalTo: glassCard.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: glassCard.centerYAnchor),
        ])

        setupTapGesture()
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        HapticManager.shared.cardTap()

        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5
            ) {
                self.transform = .identity
            }
        }

        pulseIcon()
    }

    private func pulseIcon() {
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.iconContainerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.iconContainerView.backgroundColor = self.accentColor.withAlphaComponent(0.3)
            }
        ) { _ in
            UIView.animate(withDuration: 0.15) {
                self.iconContainerView.transform = .identity
                self.iconContainerView.backgroundColor = self.accentColor.withAlphaComponent(0.15)
            }
        }
    }

    public func updateValue(_ value: String) {
        if let numericValue = Double(
            value.replacingOccurrences(of: "%", with: "").replacingOccurrences(of: ",", with: ""))
        {
            if value.contains("%") {
                valueLabel.suffix = "%"
            }
            valueLabel.countFrom(0, to: numericValue, duration: 1.0)
        } else {
            valueLabel.text = value
        }
    }

    public func updateValueInstantly(_ value: String) {
        valueLabel.text = value
    }

    func addGlow() {
        glassCard.addGlow(color: accentColor, radius: 15)
    }

    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
}
