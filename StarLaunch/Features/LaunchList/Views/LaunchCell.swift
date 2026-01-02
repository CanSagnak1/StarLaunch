//
//  LaunchCell.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import UIKit

final class LaunchCell: UITableViewCell {

    static let reuseID = "LaunchCell"

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.glassBorder.cgColor
        return view
    }()

    private let gradientBorderLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            Colors.accentPurple.withAlphaComponent(0.5).cgColor,
            Colors.accentBlue.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor,
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let patchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = Colors.cardBackgroundLight
        return imageView
    }()

    private let imageOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.glassBorder.cgColor
        return view
    }()

    private let missionNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 2
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Colors.subtitleColor
        return label
    }()

    private let statusBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.accentBlue.withAlphaComponent(0.2)
        view.layer.cornerRadius = 6
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = Colors.accentBlue
        return label
    }()

    private let chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let imageView = UIImageView(
            image: UIImage(systemName: "chevron.right", withConfiguration: config))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Colors.tertiaryColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.accentCyan
        label.textAlignment = .right
        return label
    }()

    private var countdownTimer: Timer?
    private var launchDate: Date?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        countdownTimer?.invalidate()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        cardView.addSubview(patchImageView)
        cardView.addSubview(imageOverlay)

        statusBadge.addSubview(statusLabel)

        let infoStack = UIStackView(arrangedSubviews: [missionNameLabel, dateLabel, statusBadge])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.alignment = .leading
        infoStack.setCustomSpacing(10, after: dateLabel)

        cardView.addSubview(infoStack)
        cardView.addSubview(chevronImageView)
        cardView.addSubview(countdownLabel)

        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: padding),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -padding),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            patchImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            patchImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            patchImageView.widthAnchor.constraint(equalToConstant: 80),
            patchImageView.heightAnchor.constraint(equalToConstant: 80),

            imageOverlay.topAnchor.constraint(equalTo: patchImageView.topAnchor),
            imageOverlay.leadingAnchor.constraint(equalTo: patchImageView.leadingAnchor),
            imageOverlay.trailingAnchor.constraint(equalTo: patchImageView.trailingAnchor),
            imageOverlay.bottomAnchor.constraint(equalTo: patchImageView.bottomAnchor),

            infoStack.leadingAnchor.constraint(
                equalTo: patchImageView.trailingAnchor, constant: 14),
            infoStack.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor, constant: -12),
            infoStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(
                equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4),

            chevronImageView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor, constant: -14),
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),

            countdownLabel.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor, constant: -8),
            countdownLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])

        setupShadow()
    }

    private func setupShadow() {
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.masksToBounds = false
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            HapticManager.shared.softTap()
            UIView.animate(withDuration: 0.1) {
                self.cardView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                self.cardView.backgroundColor = Colors.cardBackgroundLight
            }
        } else {
            UIView.animate(
                withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5
            ) {
                self.cardView.transform = .identity
                self.cardView.backgroundColor = Colors.cardBackground
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        patchImageView.image = nil
        missionNameLabel.text = nil
        dateLabel.text = nil
        statusLabel.text = nil
        countdownLabel.text = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        launchDate = nil
    }

    func configure(with launch: LaunchItem) {
        missionNameLabel.text = launch.name
        dateLabel.text = formatDate(launch.windowStart)

        configureStatus(launch)

        if let imageURLString = launch.image, let url = URL(string: imageURLString) {
            Task {
                patchImageView.image = await ImageLoader.shared.loadImage(from: url)
            }
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
            patchImageView.image = UIImage(systemName: "sparkles", withConfiguration: config)
            patchImageView.tintColor = Colors.tertiaryColor
            patchImageView.contentMode = .center
        }

        startCountdown(from: launch.windowStart)
    }

    private func configureStatus(_ launch: LaunchItem) {
        let formatter = ISO8601DateFormatter()
        let now = Date()

        if let launchDate = formatter.date(from: launch.windowStart) {
            if launchDate > now {
                let diff = launchDate.timeIntervalSince(now)
                let hoursUntilLaunch = diff / 3600

                if hoursUntilLaunch < 24 {
                    statusLabel.text = "LAUNCHING SOON"
                    statusLabel.textColor = Colors.success
                    statusBadge.backgroundColor = Colors.success.withAlphaComponent(0.15)
                } else if hoursUntilLaunch < 72 {
                    statusLabel.text = "GO FOR LAUNCH"
                    statusLabel.textColor = Colors.success
                    statusBadge.backgroundColor = Colors.success.withAlphaComponent(0.15)
                } else {
                    statusLabel.text = "SCHEDULED"
                    statusLabel.textColor = Colors.accentBlue
                    statusBadge.backgroundColor = Colors.accentBlue.withAlphaComponent(0.15)
                }
            } else {
                statusLabel.text = "LAUNCHED"
                statusLabel.textColor = Colors.subtitleColor
                statusBadge.backgroundColor = Colors.subtitleColor.withAlphaComponent(0.1)
            }
        } else {
            statusLabel.text = "TBD"
            statusLabel.textColor = Colors.warning
            statusBadge.backgroundColor = Colors.warning.withAlphaComponent(0.15)
        }
    }

    private func startCountdown(from dateString: String) {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString), date > Date() else {
            countdownLabel.text = nil
            return
        }

        launchDate = date
        updateCountdown()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
    }

    private func updateCountdown() {
        guard let launchDate = launchDate else { return }

        let now = Date()
        guard launchDate > now else {
            countdownLabel.text = "LAUNCHED"
            countdownTimer?.invalidate()
            return
        }

        let diff = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second], from: now, to: launchDate)

        if let days = diff.day, days > 0 {
            countdownLabel.text = "T-\(days)d \(diff.hour ?? 0)h"
        } else if let hours = diff.hour, hours > 0 {
            countdownLabel.text = String(
                format: "T-%02d:%02d:%02d", hours, diff.minute ?? 0, diff.second ?? 0)
        } else {
            countdownLabel.text = String(format: "T-%02d:%02d", diff.minute ?? 0, diff.second ?? 0)
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US")
            displayFormatter.dateFormat = "MMM d, yyyy • h:mm a"
            return displayFormatter.string(from: date)
        }
        return "Date TBD"
    }
}
