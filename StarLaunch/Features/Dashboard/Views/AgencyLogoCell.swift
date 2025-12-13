//
//  AgencyLogoCell.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import UIKit

final class AgencyLogoCell: UICollectionViewCell {
    
    static let reuseID = "AgencyLogoCell"
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = Colors.buttonBackground.withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            logoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    public func configure(with image: UIImage) {
        logoImageView.image = image
    }
}
