//
//  CompareViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Combine
import UIKit

final class CompareViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = CompareViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements

    private let gradientBackgroundLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#0A0F1C").cgColor,
            UIColor(hex: "#1E1B4B").cgColor,
            UIColor(hex: "#0F172A").cgColor,
        ]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let starsOverlayView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background_3")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.25
        return imageView
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cardBackground.withAlphaComponent(0.5)
        return view
    }()

    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(CompareRowCell.self, forCellReuseIdentifier: CompareRowCell.identifier)
        return table
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16

        let iconView = UIImageView(image: UIImage(systemName: "chart.bar.xaxis"))
        iconView.tintColor = Colors.subtitleColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = L10n.compareEmpty
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = Colors.titleColor
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.compareSelectLaunches
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = Colors.subtitleColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let addButton = GradientButton()
        addButton.setTitle("  " + L10n.compareSelectLaunches, for: .normal)
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .white
        addButton.addTarget(self, action: #selector(showLaunchSelection), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(addButton)

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])

        return view
    }()

    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(showLaunchSelection)
        )
        button.tintColor = Colors.accentBlue
        return button
    }()

    private lazy var clearButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: L10n.compareClear,
            style: .plain,
            target: self,
            action: #selector(clearAllLaunches)
        )
        button.tintColor = Colors.error
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
        updateEmptyState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        headerView.addSubview(headerStackView)

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),

            headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            headerStackView.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor, constant: -16),
            headerStackView.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor, constant: -12),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupNavigationBar() {
        title = L10n.compareTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [addButton, clearButton]
    }

    private func bindViewModel() {
        viewModel.$selectedLaunches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] launches in
                self?.updateHeaderView(with: launches)
                self?.updateEmptyState()
                self?.updateNavigationButtons()
            }
            .store(in: &cancellables)

        viewModel.$comparisonRows
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - UI Updates

    private func updateHeaderView(with launches: [LaunchItem]) {
        // Remove old views
        headerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, launch) in launches.enumerated() {
            let card = createLaunchHeaderCard(launch: launch, index: index)
            headerStackView.addArrangedSubview(card)
        }

        // Add placeholder slots if needed
        let placeholderCount = CompareViewModel.maxComparisons - launches.count
        for _ in 0..<placeholderCount {
            let placeholder = createPlaceholderCard()
            headerStackView.addArrangedSubview(placeholder)
        }
    }

    private func createLaunchHeaderCard(launch: LaunchItem, index: Int) -> UIView {
        let card = GlassCard()
        card.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4

        let nameLabel = UILabel()
        nameLabel.text = launch.name
        nameLabel.font = .systemFont(ofSize: 12, weight: .bold)
        nameLabel.textColor = Colors.titleColor
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        let providerLabel = UILabel()
        providerLabel.text = launch.provider.name
        providerLabel.font = .systemFont(ofSize: 10, weight: .medium)
        providerLabel.textColor = Colors.subtitleColor
        providerLabel.textAlignment = .center

        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = Colors.error
        removeButton.tag = index
        removeButton.addTarget(self, action: #selector(removeLaunch(_:)), for: .touchUpInside)

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(providerLabel)
        stackView.addArrangedSubview(removeButton)

        card.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
        ])

        return card
    }

    private func createPlaceholderCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Colors.cardBackground.withAlphaComponent(0.3)
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 2
        card.layer.borderColor = Colors.glassBorder.cgColor

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = Colors.subtitleColor
        button.addTarget(self, action: #selector(showLaunchSelection), for: .touchUpInside)

        card.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        return card
    }

    private func updateEmptyState() {
        emptyStateView.isHidden = viewModel.hasLaunches
        headerView.isHidden = !viewModel.hasLaunches
        tableView.isHidden = !viewModel.hasLaunches
    }

    private func updateNavigationButtons() {
        addButton.isEnabled = viewModel.canAddMore
        clearButton.isEnabled = viewModel.hasLaunches
    }

    // MARK: - Actions

    @objc private func showLaunchSelection() {
        HapticManager.shared.buttonTap()
        let selectionVC = LaunchSelectionViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: selectionVC)
        present(nav, animated: true)
    }

    @objc private func clearAllLaunches() {
        HapticManager.shared.buttonTap()

        let alert = UIAlertController(
            title: L10n.compareClear,
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: L10n.compareClear, style: .destructive) { [weak self] _ in
                self?.viewModel.clearAll()
            })
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        present(alert, animated: true)
    }

    @objc private func removeLaunch(_ sender: UIButton) {
        HapticManager.shared.lightTap()
        viewModel.removeLaunch(at: sender.tag)
    }
}

// MARK: - UITableViewDataSource

extension CompareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.comparisonRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CompareRowCell.identifier, for: indexPath) as? CompareRowCell
        else {
            return UITableViewCell()
        }

        let row = viewModel.comparisonRows[indexPath.row]
        cell.configure(with: row)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CompareViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

// MARK: - Compare Row Cell

final class CompareRowCell: UITableViewCell {
    static let identifier = "CompareRowCell"

    private let containerView: GlassCard = {
        let view = GlassCard()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Colors.accentCyan
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = Colors.subtitleColor
        return label
    }()

    private let valuesStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
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
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valuesStackView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -12),

            valuesStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valuesStackView.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor, constant: 12),
            valuesStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -12),
            valuesStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -8),
        ])
    }

    func configure(with row: ComparisonRow) {
        iconView.image = UIImage(systemName: row.iconSystemName)
        titleLabel.text = row.title.uppercased()

        // Clear old values
        valuesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for value in row.values {
            let label = UILabel()
            label.text = value
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textColor = Colors.titleColor
            label.textAlignment = .center
            label.numberOfLines = 2
            label.minimumScaleFactor = 0.7
            label.adjustsFontSizeToFitWidth = true
            valuesStackView.addArrangedSubview(label)
        }
    }
}
