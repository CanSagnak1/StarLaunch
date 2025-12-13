//
//  LaunchDetailViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import UIKit

final class LaunchDetailViewController: UIViewController {
    
    private var viewModel: LaunchDetailViewModel
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background_3")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var launchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .black.withAlphaComponent(0.3)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.subtitleColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var missionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = Colors.titleColor.withAlphaComponent(0.9)
        return label
    }()

    private lazy var rocketInfoView = InfoRowView(iconSystemName: "airplane", title: "Rocket", value: "...")
    private lazy var launchPadInfoView = InfoRowView(iconSystemName: "location.fill", title: "Launch Pad", value: "...")
    private lazy var serviceProviderInfoView = InfoRowView(iconSystemName: "person.3.fill", title: "Provider", value: "...")

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [rocketInfoView, launchPadInfoView, serviceProviderInfoView])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var crewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Colors.titleColor
        label.text = "Crew"
        label.isHidden = true
        return label
    }()

    private lazy var astronautsContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var astronautListVC: AstronautListViewController?
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, dateLabel, missionDescriptionLabel, infoStackView, crewTitleLabel, astronautsContainerView])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(24, after: missionDescriptionLabel)
        stackView.setCustomSpacing(24, after: infoStackView)
        return stackView
    }()
    
    init(viewModel: LaunchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.title = "Launch Detail"
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchLaunchDetail()
    }
    
    private func bindViewModel() {
        viewModel.updateUI = { [weak self] launchDetail in
            DispatchQueue.main.async {
                self?.updateUIWith(launchDetail)
            }
        }
        viewModel.showError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
        viewModel.updateLoadingStatus = { isLoading in
            print("Loading: \(isLoading)")
        }
    }
    
    private func updateUIWith(_ launchDetail: LaunchDetail) {
        nameLabel.text = launchDetail.name
        statusLabel.text = launchDetail.status.name.uppercased()
        statusLabel.backgroundColor = statusColor(for: launchDetail.status.name)
        
        dateLabel.text = formatDate(launchDetail.net)

        missionDescriptionLabel.text = launchDetail.mission?.description ?? "No mission description available."
        
        rocketInfoView.updateValue(launchDetail.rocket.configuration.fullName)
        launchPadInfoView.updateValue("\(launchDetail.pad.name), \(launchDetail.pad.location.name)")
        serviceProviderInfoView.updateValue(launchDetail.launchServiceProvider.name)

        if let imageUrlString = launchDetail.image, let url = URL(string: imageUrlString) {
            Task {
                launchImageView.image = await ImageLoader.shared.loadImage(from: url)
            }
        }

        let astronauts = launchDetail.program.first?.crew?.map { $0.astronaut } ?? []
        if !astronauts.isEmpty {
            crewTitleLabel.isHidden = false
            astronautsContainerView.isHidden = false
            updateAstronauts(with: astronauts)
        } else {
            crewTitleLabel.isHidden = true
            astronautsContainerView.isHidden = true
        }
    }

    private func updateAstronauts(with astronauts: [Astronaut]) {
        if astronautListVC == nil {
            astronautListVC = AstronautListViewController(astronauts: astronauts)
            guard let astronautListVC = astronautListVC else { return }
            
            addChild(astronautListVC)
            astronautsContainerView.addSubview(astronautListVC.view)
            astronautListVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                astronautListVC.view.topAnchor.constraint(equalTo: astronautsContainerView.topAnchor),
                astronautListVC.view.bottomAnchor.constraint(equalTo: astronautsContainerView.bottomAnchor),
                astronautListVC.view.leadingAnchor.constraint(equalTo: astronautsContainerView.leadingAnchor),
                astronautListVC.view.trailingAnchor.constraint(equalTo: astronautsContainerView.trailingAnchor)
            ])
            astronautListVC.didMove(toParent: self)
        } else {
            astronautListVC?.update(with: astronauts)
        }
    }
        
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US")
            return displayFormatter.string(from: date)
        }
        return "Date TBD"
    }
    
    private func statusColor(for statusName: String) -> UIColor {
        switch statusName.lowercased() {
        case "success", "go": return .systemGreen
        case "failure": return .systemRed
        case "in flight": return .systemIndigo
        default: return .systemOrange
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
        
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(launchImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(mainStackView)
        
        let padding: CGFloat = 16.0
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            launchImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            launchImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            launchImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            launchImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),

            statusLabel.topAnchor.constraint(equalTo: launchImageView.topAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: launchImageView.trailingAnchor, constant: -8),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 28),

            mainStackView.topAnchor.constraint(equalTo: launchImageView.bottomAnchor, constant: padding),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),

            astronautsContainerView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}
