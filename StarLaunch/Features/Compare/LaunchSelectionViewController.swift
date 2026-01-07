//
//  LaunchSelectionViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Combine
import UIKit

/// ViewController for selecting launches to compare
final class LaunchSelectionViewController: UIViewController {

    // MARK: - Properties

    private let compareViewModel: CompareViewModel
    private let launchViewModel = LaunchListViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements

    private let gradientBackgroundLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#0A0F1C").cgColor,
            UIColor(hex: "#1E1B4B").cgColor,
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.separatorColor = Colors.glassBorder
        table.delegate = self
        table.dataSource = self
        table.register(
            LaunchSelectionCell.self, forCellReuseIdentifier: LaunchSelectionCell.identifier)
        return table
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = Colors.titleColor
        return indicator
    }()

    private lazy var doneButton: UIBarButtonItem = {
        UIBarButtonItem(
            title: L10n.done,
            style: .done,
            target: self,
            action: #selector(dismissView)
        )
    }()

    // MARK: - Initialization

    init(viewModel: CompareViewModel) {
        self.compareViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
        launchViewModel.fetchLaunches()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupNavigationBar() {
        title = L10n.compareSelectLaunches
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.tintColor = Colors.accentBlue
    }

    private func bindViewModel() {
        launchViewModel.$launchItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        launchViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func dismissView() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension LaunchSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        launchViewModel.launchItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LaunchSelectionCell.identifier, for: indexPath)
                as? LaunchSelectionCell
        else {
            return UITableViewCell()
        }

        let launch = launchViewModel.launchItems[indexPath.row]
        let isSelected = compareViewModel.isSelected(launch)
        let canSelect = compareViewModel.canAddMore || isSelected

        cell.configure(with: launch, isSelected: isSelected, isEnabled: canSelect)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LaunchSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let launch = launchViewModel.launchItems[indexPath.row]

        if compareViewModel.isSelected(launch) {
            HapticManager.shared.lightTap()
            compareViewModel.removeLaunch(launch)
        } else if compareViewModel.canAddMore {
            HapticManager.shared.buttonTap()
            compareViewModel.addLaunch(launch)
        } else {
            HapticManager.shared.error()
            showMaxSelectedAlert()
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    private func showMaxSelectedAlert() {
        let alert = UIAlertController(
            title: L10n.compareMaxSelected,
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Launch Selection Cell

final class LaunchSelectionCell: UITableViewCell {
    static let identifier = "LaunchSelectionCell"

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cardBackground.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = Colors.titleColor
        label.numberOfLines = 2
        return label
    }()

    private let providerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Colors.subtitleColor
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = Colors.tertiaryColor
        return label
    }()

    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Colors.success
        imageView.contentMode = .scaleAspectFit
        return imageView
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

        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(providerLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(checkmarkView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            checkmarkView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(
                equalTo: checkmarkView.leadingAnchor, constant: -12),

            providerLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            providerLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 16),
            providerLabel.trailingAnchor.constraint(
                equalTo: checkmarkView.leadingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: providerLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(
                equalTo: checkmarkView.leadingAnchor, constant: -12),
        ])
    }

    func configure(with launch: LaunchItem, isSelected: Bool, isEnabled: Bool) {
        nameLabel.text = launch.name
        providerLabel.text = launch.provider.name
        dateLabel.text = formatDate(launch.windowStart)

        checkmarkView.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        checkmarkView.tintColor = isSelected ? Colors.success : Colors.subtitleColor

        containerView.alpha = isEnabled ? 1.0 : 0.5
        containerView.backgroundColor =
            isSelected
            ? Colors.success.withAlphaComponent(0.1)
            : Colors.cardBackground.withAlphaComponent(0.5)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return L10n.detailTbd
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
}
