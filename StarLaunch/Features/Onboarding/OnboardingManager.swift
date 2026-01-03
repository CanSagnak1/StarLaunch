//
//  OnboardingManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import Foundation

final class OnboardingManager {
    static let shared = OnboardingManager()

    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private let onboardingVersionKey = "onboardingVersion"
    private let currentOnboardingVersion = 1

    private init() {}

    var hasSeenOnboarding: Bool {
        get {
            let seenVersion = UserDefaults.standard.integer(forKey: onboardingVersionKey)
            return seenVersion >= currentOnboardingVersion
        }
        set {
            if newValue {
                UserDefaults.standard.set(currentOnboardingVersion, forKey: onboardingVersionKey)
            } else {
                UserDefaults.standard.removeObject(forKey: onboardingVersionKey)
            }
        }
    }

    var shouldShowOnboarding: Bool {
        return !hasSeenOnboarding
    }

    func markOnboardingComplete() {
        hasSeenOnboarding = true
    }

    func reset() {
        hasSeenOnboarding = false
        UserDefaults.standard.removeObject(forKey: hasSeenOnboardingKey)
        UserDefaults.standard.removeObject(forKey: onboardingVersionKey)
    }
}
