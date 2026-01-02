//
//  SkeletonView.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import UIKit

final class SkeletonView: UIView {

    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = Colors.buttonBackground.withAlphaComponent(0.5)
        layer.cornerRadius = 8
        clipsToBounds = true

        gradientLayer.colors = [
            UIColor.gray.withAlphaComponent(0.3).cgColor,
            UIColor.gray.withAlphaComponent(0.6).cgColor,
            UIColor.gray.withAlphaComponent(0.3).cgColor,
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: "shimmer")
    }

    func stopAnimating() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}

final class SkeletonCell: UITableViewCell {
    static let reuseID = "SkeletonCell"

    private let imageViewSkeleton = SkeletonView()
    private let titleSkeleton = SkeletonView()
    private let subtitleSkeleton = SkeletonView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        let cardContainer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.layer.cornerRadius = 15
        cardContainer.clipsToBounds = true
        contentView.addSubview(cardContainer)

        imageViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        imageViewSkeleton.layer.cornerRadius = 12
        cardContainer.contentView.addSubview(imageViewSkeleton)

        titleSkeleton.translatesAutoresizingMaskIntoConstraints = false
        titleSkeleton.layer.cornerRadius = 6
        cardContainer.contentView.addSubview(titleSkeleton)

        subtitleSkeleton.translatesAutoresizingMaskIntoConstraints = false
        subtitleSkeleton.layer.cornerRadius = 4
        cardContainer.contentView.addSubview(subtitleSkeleton)

        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: padding),
            cardContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -padding),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            imageViewSkeleton.leadingAnchor.constraint(
                equalTo: cardContainer.contentView.leadingAnchor, constant: padding),
            imageViewSkeleton.centerYAnchor.constraint(
                equalTo: cardContainer.contentView.centerYAnchor),
            imageViewSkeleton.widthAnchor.constraint(equalToConstant: 90),
            imageViewSkeleton.heightAnchor.constraint(equalToConstant: 90),

            titleSkeleton.leadingAnchor.constraint(
                equalTo: imageViewSkeleton.trailingAnchor, constant: padding),
            titleSkeleton.trailingAnchor.constraint(
                equalTo: cardContainer.contentView.trailingAnchor, constant: -padding),
            titleSkeleton.topAnchor.constraint(equalTo: imageViewSkeleton.topAnchor, constant: 8),
            titleSkeleton.heightAnchor.constraint(equalToConstant: 20),

            subtitleSkeleton.leadingAnchor.constraint(equalTo: titleSkeleton.leadingAnchor),
            subtitleSkeleton.topAnchor.constraint(
                equalTo: titleSkeleton.bottomAnchor, constant: 12),
            subtitleSkeleton.widthAnchor.constraint(
                equalTo: titleSkeleton.widthAnchor, multiplier: 0.7),
            subtitleSkeleton.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    func startAnimating() {
        imageViewSkeleton.startAnimating()
        titleSkeleton.startAnimating()
        subtitleSkeleton.startAnimating()
    }

    func stopAnimating() {
        imageViewSkeleton.stopAnimating()
        titleSkeleton.stopAnimating()
        subtitleSkeleton.stopAnimating()
    }
}
