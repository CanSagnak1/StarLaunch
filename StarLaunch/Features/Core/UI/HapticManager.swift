//
//  HapticManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import UIKit

final class HapticManager {

    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        softImpact.prepare()
        rigidImpact.prepare()
        selection.prepare()
        notification.prepare()
    }


    func lightTap() {
        lightImpact.impactOccurred()
    }

    func mediumTap() {
        mediumImpact.impactOccurred()
    }

    func heavyTap() {
        heavyImpact.impactOccurred()
    }

    func softTap() {
        softImpact.impactOccurred()
    }

    func rigidTap() {
        rigidImpact.impactOccurred()
    }


    func selectionChanged() {
        selection.selectionChanged()
    }


    func success() {
        notification.notificationOccurred(.success)
    }

    func warning() {
        notification.notificationOccurred(.warning)
    }

    func error() {
        notification.notificationOccurred(.error)
    }


    func buttonTap() {
        lightImpact.impactOccurred(intensity: 0.7)
    }

    func cardTap() {
        softImpact.impactOccurred(intensity: 0.5)
    }

    func swipeAction() {
        mediumImpact.impactOccurred(intensity: 0.8)
    }

    func pullToRefresh() {
        rigidImpact.impactOccurred(intensity: 0.6)
    }

    func navigation() {
        softImpact.impactOccurred(intensity: 0.4)
    }

    func favorite() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let secondGenerator = UIImpactFeedbackGenerator(style: .light)
            secondGenerator.impactOccurred()
        }
    }

    func countdown() {
        lightImpact.impactOccurred(intensity: 0.3)
    }

    func launch() {
        heavyImpact.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.mediumImpact.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.lightImpact.impactOccurred()
        }
    }
}
