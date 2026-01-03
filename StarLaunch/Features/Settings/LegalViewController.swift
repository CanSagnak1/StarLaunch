//
//  LegalViewController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import UIKit
import WebKit

enum LegalDocumentType {
    case privacyPolicy
    case termsOfUse

    var title: String {
        switch self {
        case .privacyPolicy: return L10n.settingsPrivacyPolicy
        case .termsOfUse: return L10n.settingsTermsOfUse
        }
    }

    var htmlContent: String {
        switch self {
        case .privacyPolicy:
            return privacyPolicyHTML
        case .termsOfUse:
            return termsOfUseHTML
        }
    }
}

final class LegalViewController: UIViewController {

    private let documentType: LegalDocumentType

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

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(type: LegalDocumentType) {
        self.documentType = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBackgroundLayer.frame = view.bounds
    }

    private func setupUI() {
        title = documentType.title
        view.backgroundColor = Colors.appBackground
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)

        view.addSubview(webView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        webView.navigationDelegate = self
    }

    private func loadContent() {
        activityIndicator.startAnimating()
        webView.loadHTMLString(documentType.htmlContent, baseURL: nil)
    }
}

extension LegalViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}

private let privacyPolicyHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                padding: 20px;
                color: #F9FAFB;
                background-color: transparent;
                line-height: 1.6;
            }
            h1 { color: #06B6D4; font-size: 24px; margin-bottom: 20px; }
            h2 { color: #8B5CF6; font-size: 18px; margin-top: 24px; }
            p { color: #9CA3AF; margin: 12px 0; }
            ul { color: #9CA3AF; padding-left: 20px; }
            li { margin: 8px 0; }
            .date { color: #6B7280; font-size: 14px; margin-bottom: 24px; }
        </style>
    </head>
    <body>
        <h1>Privacy Policy</h1>
        <p class="date">Last updated: January 3, 2026</p>
        
        <p>Welcome to StarLaunch. We respect your privacy and are committed to protecting your personal data.</p>
        
        <h2>Information We Collect</h2>
        <p>StarLaunch collects minimal data to provide you with the best experience:</p>
        <ul>
            <li><strong>Usage Data:</strong> We may collect anonymous usage statistics to improve the app</li>
            <li><strong>Favorites:</strong> Your favorite launches are stored locally on your device</li>
            <li><strong>Notifications:</strong> If enabled, we store notification preferences locally</li>
        </ul>
        
        <h2>Data Storage</h2>
        <p>All your personal data (favorites, preferences) is stored locally on your device. We do not upload or store your personal information on external servers.</p>
        
        <h2>Third-Party Services</h2>
        <p>StarLaunch uses The Space Devs API to fetch launch data. This is public data and no personal information is shared with this service.</p>
        
        <h2>Your Rights</h2>
        <p>You have the right to:</p>
        <ul>
            <li>Access your data stored in the app</li>
            <li>Delete your data by clearing app data or uninstalling</li>
            <li>Opt-out of analytics by disabling in your device settings</li>
        </ul>
        
        <h2>Contact Us</h2>
        <p>If you have any questions about this Privacy Policy, please contact us at:</p>
        <p>Contact Me: https://github.com/CanSagnak1/</p>
    </body>
    </html>
    """

private let termsOfUseHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                padding: 20px;
                color: #F9FAFB;
                background-color: transparent;
                line-height: 1.6;
            }
            h1 { color: #06B6D4; font-size: 24px; margin-bottom: 20px; }
            h2 { color: #8B5CF6; font-size: 18px; margin-top: 24px; }
            p { color: #9CA3AF; margin: 12px 0; }
            ul { color: #9CA3AF; padding-left: 20px; }
            li { margin: 8px 0; }
            .date { color: #6B7280; font-size: 14px; margin-bottom: 24px; }
        </style>
    </head>
    <body>
        <h1>Terms of Use</h1>
        <p class="date">Last updated: January 3, 2026</p>
        
        <p>By downloading or using StarLaunch, you agree to these Terms of Use.</p>
        
        <h2>Acceptable Use</h2>
        <p>You agree to use StarLaunch only for lawful purposes and in accordance with these Terms. You agree not to:</p>
        <ul>
            <li>Use the app in any way that violates applicable laws</li>
            <li>Attempt to reverse engineer or extract source code</li>
            <li>Use automated systems to access the app</li>
            <li>Interfere with the proper working of the app</li>
        </ul>
        
        <h2>Intellectual Property</h2>
        <p>The app and its original content, features, and functionality are owned by StarLaunch and are protected by international copyright, trademark, and other intellectual property laws.</p>
        
        <h2>Data Accuracy</h2>
        <p>Launch data is provided by The Space Devs API. While we strive for accuracy, we cannot guarantee that all information is 100% accurate or up-to-date. Launch schedules may change without notice.</p>
        
        <h2>Disclaimer</h2>
        <p>StarLaunch is provided "as is" without any warranties, express or implied. We do not warrant that the app will be error-free or uninterrupted.</p>
        
        <h2>Limitation of Liability</h2>
        <p>In no event shall StarLaunch be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the app.</p>
        
        <h2>Changes to Terms</h2>
        <p>We reserve the right to modify these Terms at any time. We will notify users of significant changes through the app.</p>
        
        <h2>Contact</h2>
        <p>For any questions regarding these Terms, please contact:</p>
        <p>Contact Me: https://github.com/CanSagnak1/</p>
    </body>
    </html>
    """
