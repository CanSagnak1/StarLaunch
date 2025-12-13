//
//  LaunchCell.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import UIKit

final class LaunchCell: UITableViewCell {

    static let reuseID = "LaunchCell"
        
    private let cardContainerView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    private let patchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .black.withAlphaComponent(0.3)
        return imageView
    }()
    
    private let missionNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Colors.subtitleColor
        label.numberOfLines = 2
        return label
    }()
    
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
        
        contentView.addSubview(cardContainerView)
        
        cardContainerView.contentView.addSubview(patchImageView)
        
        let infoStack = UIStackView(arrangedSubviews: [missionNameLabel, dateLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.alignment = .leading
        
        cardContainerView.contentView.addSubview(infoStack)
        
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            patchImageView.leadingAnchor.constraint(equalTo: cardContainerView.contentView.leadingAnchor, constant: padding),
            patchImageView.centerYAnchor.constraint(equalTo: cardContainerView.contentView.centerYAnchor),
            patchImageView.widthAnchor.constraint(equalToConstant: 90),
            patchImageView.heightAnchor.constraint(equalToConstant: 90),
            
            infoStack.leadingAnchor.constraint(equalTo: patchImageView.trailingAnchor, constant: padding),
            infoStack.trailingAnchor.constraint(equalTo: cardContainerView.contentView.trailingAnchor, constant: -padding),
            infoStack.centerYAnchor.constraint(equalTo: cardContainerView.contentView.centerYAnchor)
        ])
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        patchImageView.image = nil
        missionNameLabel.text = nil
        dateLabel.text = nil
    }
    
    func configure(with launch: LaunchItem) {
        missionNameLabel.text = launch.name
        dateLabel.text = formatDate(launch.windowStart)
        
        if let imageURLString = launch.image, let url = URL(string: imageURLString) {
            Task {
                patchImageView.image = await ImageLoader.shared.loadImage(from: url)
            }
        } else {
            patchImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        }
    }
        
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US")
            displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            return displayFormatter.string(from: date)
        }
        return "Date TBD"
    }
}
