//
//  SettingsViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import StoreKit
import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - Properties
    private weak var coordinator: MainTabBarController?

    private enum Section: Int, CaseIterable {
        case language
        case general
        case legal
        case app

        var title: String {
            switch self {
            case .language: return L10n.settingsSectionLanguage
            case .general: return L10n.settingsSectionGeneral
            case .legal: return L10n.settingsSectionLegal
            case .app: return L10n.settingsSectionApp
            }
        }
    }

    private enum LanguageRow: Int, CaseIterable {
        case selectLanguage

        var title: String {
            return L10n.settingsLanguage
        }

        var icon: String {
            return "globe"
        }

        var iconColor: UIColor {
            return Colors.accentBlue
        }
    }

    private enum GeneralRow: Int, CaseIterable {
        case onboarding
        case clearCache

        var title: String {
            switch self {
            case .onboarding: return L10n.settingsOnboarding
            case .clearCache: return L10n.settingsClearCache
            }
        }

        var icon: String {
            switch self {
            case .onboarding: return "sparkles"
            case .clearCache: return "trash"
            }
        }

        var iconColor: UIColor {
            switch self {
            case .onboarding: return Colors.accentCyan
            case .clearCache: return Colors.error
            }
        }
    }

    private enum LegalRow: Int, CaseIterable {
        case privacyPolicy
        case termsOfUse

        var title: String {
            switch self {
            case .privacyPolicy: return L10n.settingsPrivacyPolicy
            case .termsOfUse: return L10n.settingsTermsOfUse
            }
        }

        var icon: String {
            switch self {
            case .privacyPolicy: return "hand.raised.fill"
            case .termsOfUse: return "doc.text.fill"
            }
        }

        var iconColor: UIColor {
            switch self {
            case .privacyPolicy: return Colors.accentPurple
            case .termsOfUse: return Colors.accentBlue
            }
        }
    }

    private enum AppRow: Int, CaseIterable {
        case rateApp
        case shareApp

        var title: String {
            switch self {
            case .rateApp: return L10n.settingsRateApp
            case .shareApp: return L10n.settingsShareApp
            }
        }

        var icon: String {
            switch self {
            case .rateApp: return "star.fill"
            case .shareApp: return "square.and.arrow.up"
            }
        }

        var iconColor: UIColor {
            switch self {
            case .rateApp: return Colors.warning
            case .shareApp: return Colors.success
            }
        }
    }

    // MARK: - UI Components
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
        imageView.image = UIImage(named: "background_2")
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.25
        return imageView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = Colors.glassBorder
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
        return tableView
    }()

    // MARK: - Initialization
    init(coordinator: MainTabBarController?) {
        self.coordinator = coordinator
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
        setupLanguageObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupLanguageObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
    }

    @objc private func languageDidChange() {
        setupNavigationBar()
        tableView.reloadData()

        // Update tab bar item
        tabBarItem.title = L10n.tabSettings
    }

    private func setupNavigationBar() {
        title = L10n.settingsTitle

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupUI() {
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(starsOverlayView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            starsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            starsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Actions
    private func showLanguagePicker() {
        HapticManager.shared.buttonTap()

        let alert = UIAlertController(
            title: L10n.settingsSelectLanguage,
            message: nil,
            preferredStyle: .actionSheet
        )

        for language in Language.allCases {
            let action = UIAlertAction(title: language.displayName, style: .default) {
                [weak self] _ in
                self?.changeLanguage(to: language)
            }

            // Check mark for current language
            if language == LocalizationManager.shared.currentLanguage {
                action.setValue(true, forKey: "checked")
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }

        present(alert, animated: true)
    }

    private func changeLanguage(to language: Language) {
        LocalizationManager.shared.setLanguage(language)
        HapticManager.shared.success()

        // Notify coordinator to refresh all tabs
        coordinator?.refreshAllTabsForLanguageChange()
    }

    private func showOnboarding() {
        HapticManager.shared.buttonTap()
        coordinator?.showOnboarding()
    }

    private func clearCache() {
        HapticManager.shared.buttonTap()

        let alert = UIAlertController(
            title: L10n.settingsClearCache,
            message: L10n.settingsClearCacheMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        alert.addAction(
            UIAlertAction(title: L10n.settingsClearCache, style: .destructive) { _ in
                CacheManager.shared.clearAll()
                HapticManager.shared.success()

                let successAlert = UIAlertController(
                    title: L10n.success,
                    message: L10n.settingsClearCacheSuccess,
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: L10n.ok, style: .default))
                self.present(successAlert, animated: true)
            })

        present(alert, animated: true)
    }

    private func showPrivacyPolicy() {
        HapticManager.shared.buttonTap()
        let legalVC = LegalViewController(type: .privacyPolicy)
        navigationController?.pushViewController(legalVC, animated: true)
    }

    private func showTermsOfUse() {
        HapticManager.shared.buttonTap()
        let legalVC = LegalViewController(type: .termsOfUse)
        navigationController?.pushViewController(legalVC, animated: true)
    }

    private func rateApp() {
        HapticManager.shared.buttonTap()

        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func shareApp() {
        HapticManager.shared.buttonTap()

        let appURL = URL(string: "https://apps.apple.com/app/starlaunch")!
        let text = L10n.shareText

        let activityVC = UIActivityViewController(
            activityItems: [text, appURL],
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }

        present(activityVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .language: return LanguageRow.allCases.count
        case .general: return GeneralRow.allCases.count
        case .legal: return LegalRow.allCases.count
        case .app: return AppRow.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsCell.reuseID,
                for: indexPath
            ) as? SettingsCell
        else {
            return UITableViewCell()
        }

        guard let section = Section(rawValue: indexPath.section) else { return cell }

        switch section {
        case .language:
            if let row = LanguageRow(rawValue: indexPath.row) {
                let currentLang = LocalizationManager.shared.currentLanguage.displayName
                cell.configure(
                    title: row.title,
                    icon: row.icon,
                    iconColor: row.iconColor,
                    showDisclosure: true,
                    detailText: currentLang
                )
            }
        case .general:
            if let row = GeneralRow(rawValue: indexPath.row) {
                cell.configure(title: row.title, icon: row.icon, iconColor: row.iconColor)
            }
        case .legal:
            if let row = LegalRow(rawValue: indexPath.row) {
                cell.configure(
                    title: row.title, icon: row.icon, iconColor: row.iconColor, showDisclosure: true
                )
            }
        case .app:
            if let row = AppRow(rawValue: indexPath.row) {
                cell.configure(title: row.title, icon: row.icon, iconColor: row.iconColor)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == Section.app.rawValue {
            let version =
                Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            return "StarLaunch v\(version) (\(build))"
        }
        return nil
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .language:
            if let row = LanguageRow(rawValue: indexPath.row) {
                switch row {
                case .selectLanguage: showLanguagePicker()
                }
            }
        case .general:
            if let row = GeneralRow(rawValue: indexPath.row) {
                switch row {
                case .onboarding: showOnboarding()
                case .clearCache: clearCache()
                }
            }
        case .legal:
            if let row = LegalRow(rawValue: indexPath.row) {
                switch row {
                case .privacyPolicy: showPrivacyPolicy()
                case .termsOfUse: showTermsOfUse()
                }
            }
        case .app:
            if let row = AppRow(rawValue: indexPath.row) {
                switch row {
                case .rateApp: rateApp()
                case .shareApp: shareApp()
                }
            }
        }
    }

    func tableView(
        _ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int
    ) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Colors.tertiaryColor
            header.textLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        }
    }

    func tableView(
        _ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int
    ) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = Colors.tertiaryColor
            footer.textLabel?.textAlignment = .center
        }
    }
}

// MARK: - SettingsCell
final class SettingsCell: UITableViewCell {
    static let reuseID = "SettingsCell"

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = Colors.titleColor
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = Colors.tertiaryColor
        label.textAlignment = .right
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
        backgroundColor = Colors.cardBackground.withAlphaComponent(0.6)

        let selectedView = UIView()
        selectedView.backgroundColor = Colors.buttonBackgroundHighlight
        selectedBackgroundView = selectedView

        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(iconContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalToConstant: 32),
            iconContainerView.topAnchor.constraint(
                greaterThanOrEqualTo: contentView.topAnchor, constant: 11),
            iconContainerView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -11),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            detailLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -40),
            detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(
        title: String, icon: String, iconColor: UIColor, showDisclosure: Bool = false,
        detailText: String? = nil
    ) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        iconContainerView.backgroundColor = iconColor.withAlphaComponent(0.2)
        iconImageView.tintColor = iconColor
        accessoryType = showDisclosure ? .disclosureIndicator : .none
        detailLabel.text = detailText
        detailLabel.isHidden = detailText == nil
    }
}
