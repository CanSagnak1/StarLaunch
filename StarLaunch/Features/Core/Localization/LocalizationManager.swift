//
//  LocalizationManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import Foundation

enum Language: String, CaseIterable {
    case english = "en"
    case turkish = "tr"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }

    var localizedDisplayName: String {
        switch self {
        case .english: return L10n.languageEnglish
        case .turkish: return L10n.languageTurkish
        }
    }

    var code: String {
        return rawValue
    }
}

final class LocalizationManager {
    static let shared = LocalizationManager()

    private let userDefaultsKey = "app_language"
    private var bundle: Bundle?

    static let languageDidChangeNotification = Notification.Name("languageDidChange")

    var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: userDefaultsKey)
            loadBundle()
            NotificationCenter.default.post(
                name: LocalizationManager.languageDidChangeNotification, object: nil)
        }
    }

    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: userDefaultsKey),
            let language = Language(rawValue: savedLanguage)
        {
            currentLanguage = language
        } else {
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.hasPrefix("tr") {
                currentLanguage = .turkish
            } else {
                currentLanguage = .english
            }
        }
        loadBundle()
    }

    private func loadBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
            let languageBundle = Bundle(path: path)
        else {
            bundle = Bundle.main
            return
        }
        bundle = languageBundle
    }

    func localizedString(for key: String) -> String {
        return bundle?.localizedString(forKey: key, value: key, table: nil) ?? key
    }

    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }
}

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}

enum L10n {
    static var ok: String { "common.ok".localized }
    static var cancel: String { "common.cancel".localized }
    static var error: String { "common.error".localized }
    static var loading: String { "common.loading".localized }
    static var retry: String { "common.retry".localized }
    static var done: String { "common.done".localized }
    static var close: String { "common.close".localized }
    static var success: String { "common.success".localized }
    static var commonPullToRefresh: String { "common.pullToRefresh".localized }

    static var tabDashboard: String { "tab.dashboard".localized }
    static var tabLaunches: String { "tab.launches".localized }
    static var tabFavorites: String { "tab.favorites".localized }
    static var tabCompare: String { "tab.compare".localized }
    static var tabSettings: String { "tab.settings".localized }

    static var splashTitle: String { "splash.title".localized }
    static var splashTagline: String { "splash.tagline".localized }
    static var splashLoading: String { "splash.loading".localized }
    static var splashReady: String { "splash.ready".localized }

    static var onboardingWelcomeTitle: String { "onboarding.welcome.title".localized }
    static var onboardingWelcomeDesc: String { "onboarding.welcome.description".localized }
    static var onboardingCountdownTitle: String { "onboarding.countdown.title".localized }
    static var onboardingCountdownDesc: String { "onboarding.countdown.description".localized }
    static var onboardingNotificationsTitle: String { "onboarding.notifications.title".localized }
    static var onboardingNotificationsDesc: String {
        "onboarding.notifications.description".localized
    }
    static var onboardingFavoritesTitle: String { "onboarding.favorites.title".localized }
    static var onboardingFavoritesDesc: String { "onboarding.favorites.description".localized }
    static var onboardingGetStarted: String { "onboarding.getStarted".localized }
    static var onboardingSkip: String { "onboarding.skip".localized }
    static var onboardingNext: String { "onboarding.next".localized }
    static var onboardingOfflineTitle: String { "onboarding.offline.title".localized }
    static var onboardingOfflineDesc: String { "onboarding.offline.description".localized }
    static var onboardingWidgetsTitle: String { "onboarding.widgets.title".localized }
    static var onboardingWidgetsDesc: String { "onboarding.widgets.description".localized }
    static var onboardingCalendarTitle: String { "onboarding.calendar.title".localized }
    static var onboardingCalendarDesc: String { "onboarding.calendar.description".localized }
    static var onboardingCompareTitle: String { "onboarding.compare.title".localized }
    static var onboardingCompareDesc: String { "onboarding.compare.description".localized }

    static var dashboardTitle: String { "dashboard.title".localized }
    static var dashboardStarship: String { "dashboard.starship".localized }
    static var dashboardAgencies: String { "dashboard.agencies".localized }
    static var dashboardStats: String { "dashboard.stats".localized }
    static var dashboardTotalLaunches: String { "dashboard.totalLaunches".localized }
    static var dashboardSuccessRate: String { "dashboard.successRate".localized }
    static var dashboardUpcoming: String { "dashboard.upcoming".localized }
    static var dashboardQuickActions: String { "dashboard.quickActions".localized }
    static var dashboardVisitSpacex: String { "dashboard.visitSpacex".localized }

    static var launchesTitle: String { "launches.title".localized }
    static var launchesEmptyTitle: String { "launches.empty.title".localized }
    static var launchesEmptyMessage: String { "launches.empty.message".localized }
    static var launchesSearch: String { "launches.search".localized }
    static var launchesOfflineMode: String { "launches.offlineMode".localized }

    static var detailMission: String { "detail.mission".localized }
    static var detailProvider: String { "detail.provider".localized }
    static var detailLocation: String { "detail.location".localized }
    static var detailRocket: String { "detail.rocket".localized }
    static var detailStatus: String { "detail.status".localized }
    static var detailWindow: String { "detail.window".localized }
    static var detailAstronauts: String { "detail.astronauts".localized }
    static var detailRemindMe: String { "detail.remindMe".localized }
    static var detailShare: String { "detail.share".localized }
    static var detailCountdown: String { "detail.countdown".localized }
    static var detailDays: String { "detail.days".localized }
    static var detailHours: String { "detail.hours".localized }
    static var detailMinutes: String { "detail.minutes".localized }
    static var detailSeconds: String { "detail.seconds".localized }
    static var detailTitle: String { "detail.title".localized }
    static var detailCrew: String { "detail.crew".localized }
    static var detailReminderSet: String { "detail.reminderSet".localized }
    static var detailTbd: String { "detail.tbd".localized }
    static var detailNoMission: String { "detail.noMission".localized }

    static var favoritesTitle: String { "favorites.title".localized }
    static var favoritesEmptyTitle: String { "favorites.empty.title".localized }
    static var favoritesEmptyMessage: String { "favorites.empty.message".localized }
    static var favoritesBrowse: String { "favorites.browse".localized }

    static var searchTitle: String { "search.title".localized }
    static var searchPlaceholder: String { "search.placeholder".localized }
    static var searchNoResults: String { "search.noResults".localized }
    static var searchRecent: String { "search.recent".localized }
    static var searchSortBy: String { "search.sortBy".localized }
    static var searchResetFilters: String { "search.resetFilters".localized }
    static var searchSortDate: String { "search.sort.date".localized }
    static var searchSortName: String { "search.sort.name".localized }
    static var searchSortProvider: String { "search.sort.provider".localized }

    static var settingsTitle: String { "settings.title".localized }
    static var settingsSectionLanguage: String { "settings.section.language".localized }
    static var settingsSectionGeneral: String { "settings.section.general".localized }
    static var settingsSectionLegal: String { "settings.section.legal".localized }
    static var settingsSectionApp: String { "settings.section.app".localized }
    static var settingsLanguage: String { "settings.language".localized }
    static var settingsOnboarding: String { "settings.onboarding".localized }
    static var settingsClearCache: String { "settings.clearCache".localized }
    static var settingsPrivacyPolicy: String { "settings.privacyPolicy".localized }
    static var settingsTermsOfUse: String { "settings.termsOfUse".localized }
    static var settingsRateApp: String { "settings.rateApp".localized }
    static var settingsShareApp: String { "settings.shareApp".localized }
    static var settingsClearCacheMessage: String { "settings.clearCache.message".localized }
    static var settingsClearCacheSuccess: String { "settings.clearCache.success".localized }
    static var settingsSelectLanguage: String { "settings.selectLanguage".localized }

    static var languageEnglish: String { "language.english".localized }
    static var languageTurkish: String { "language.turkish".localized }

    static var errorNoInternet: String { "error.noInternet".localized }
    static var errorTimeout: String { "error.timeout".localized }
    static var errorServer: String { "error.server".localized }
    static var errorGeneric: String { "error.generic".localized }

    static var emptyNoDataTitle: String { "empty.noData.title".localized }
    static var emptyNoDataMessage: String { "empty.noData.message".localized }
    static var emptyNoSearchResultsTitle: String { "empty.noSearchResults.title".localized }
    static var emptyNoSearchResultsMessage: String { "empty.noSearchResults.message".localized }
    static var emptyNoInternetTitle: String { "empty.noInternet.title".localized }
    static var emptyErrorTitle: String { "empty.error.title".localized }

    static var shareText: String { "share.text".localized }

    static var launchStatusLaunchingSoon: String { "launch.status.launchingSoon".localized }
    static var launchStatusGoForLaunch: String { "launch.status.goForLaunch".localized }
    static var launchStatusScheduled: String { "launch.status.scheduled".localized }
    static var launchStatusLaunched: String { "launch.status.launched".localized }
    static var launchStatusTbd: String { "launch.status.tbd".localized }

    // MARK: - Calendar
    static var calendarAddToCalendar: String { "calendar.addToCalendar".localized }
    static var calendarRemoveFromCalendar: String { "calendar.removeFromCalendar".localized }
    static var calendarAdded: String { "calendar.added".localized }
    static var calendarRemoved: String { "calendar.removed".localized }
    static var calendarReminderTitle: String { "calendar.reminderTitle".localized }
    static var calendarReminder15Min: String { "calendar.reminder.15min".localized }
    static var calendarReminder1Hour: String { "calendar.reminder.1hour".localized }
    static var calendarReminder1Day: String { "calendar.reminder.1day".localized }
    static var calendarNoReminder: String { "calendar.noReminder".localized }
    static var calendarErrorAccessDenied: String { "calendar.error.accessDenied".localized }
    static var calendarErrorInvalidDate: String { "calendar.error.invalidDate".localized }
    static var calendarErrorSaveFailed: String { "calendar.error.saveFailed".localized }
    static var calendarErrorDeleteFailed: String { "calendar.error.deleteFailed".localized }
    static var calendarErrorNotFound: String { "calendar.error.notFound".localized }

    // MARK: - Compare
    static var compareTitle: String { "compare.title".localized }
    static var compareSelectLaunches: String { "compare.selectLaunches".localized }
    static var compareMaxSelected: String { "compare.maxSelected".localized }
    static var compareEmpty: String { "compare.empty".localized }
    static var compareClear: String { "compare.clear".localized }
}
