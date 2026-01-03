//
//  UIComponents.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import UIKit


final class GlassCard: UIView {

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let gradientLayer = CAGradientLayer()
    private let borderGradientLayer = CAGradientLayer()

    var cornerRadius: CGFloat = 16 {
        didSet { updateCornerRadius() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = Colors.glassBackground
        blurView.contentView.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: blurView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
        ])

        layer.borderWidth = 1
        layer.borderColor = Colors.glassBorder.cgColor
    }

    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        borderGradientLayer.frame = bounds
    }

    func addGlow(color: UIColor = Colors.accentPurple, radius: CGFloat = 20) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
}


final class GradientButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    var gradientColors: [CGColor] = Colors.primaryGradient {
        didSet { updateGradient() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        layer.cornerRadius = 12
        layer.masksToBounds = true

        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)

        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        setTitleColor(.white, for: .normal)

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(
            self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func updateGradient() {
        gradientLayer.colors = gradientColors
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    @objc private func touchDown() {
        HapticManager.shared.buttonTap()
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.9
        }
    }

    @objc private func touchUp() {
        UIView.animate(
            withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}


final class AnimatedCounterLabel: UILabel {

    private var displayLink: CADisplayLink?
    private var startValue: Double = 0
    private var endValue: Double = 0
    private var startTime: CFTimeInterval = 0
    private var duration: CFTimeInterval = 1.0
    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var suffix: String = ""
    var prefix: String = ""

    func countFrom(_ from: Double, to: Double, duration: CFTimeInterval = 1.0) {
        self.startValue = from
        self.endValue = to
        self.duration = duration

        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateValue))
        startTime = CACurrentMediaTime()
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateValue() {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = min(elapsed / duration, 1.0)

        let easedProgress = 1 - pow(1 - progress, 3)

        let currentValue = startValue + (endValue - startValue) * easedProgress
        text =
            "\(prefix)\(numberFormatter.string(from: NSNumber(value: Int(currentValue))) ?? "0")\(suffix)"

        if progress >= 1.0 {
            displayLink?.invalidate()
            displayLink = nil
            text =
                "\(prefix)\(numberFormatter.string(from: NSNumber(value: Int(endValue))) ?? "0")\(suffix)"
        }
    }

    deinit {
        displayLink?.invalidate()
    }
}


final class PulsingView: UIView {

    private var pulseLayer: CALayer?

    func startPulsing(color: UIColor = Colors.accentBlue, scale: CGFloat = 1.3) {
        stopPulsing()

        let pulse = CALayer()
        pulse.frame = bounds
        pulse.cornerRadius = bounds.width / 2
        pulse.backgroundColor = color.cgColor
        pulse.opacity = 0
        layer.insertSublayer(pulse, at: 0)
        pulseLayer = pulse

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = scale

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 0

        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = 1.5
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)

        pulse.add(group, forKey: "pulse")
    }

    func stopPulsing() {
        pulseLayer?.removeFromSuperlayer()
        pulseLayer = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pulseLayer?.frame = bounds
        pulseLayer?.cornerRadius = bounds.width / 2
    }
}


final class ShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupShimmer() {
        backgroundColor = Colors.cardBackgroundLight
        layer.cornerRadius = 8
        layer.masksToBounds = true

        gradientLayer.colors = [
            Colors.cardBackgroundLight.cgColor,
            Colors.glassHighlight.cgColor,
            Colors.cardBackgroundLight.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        layer.addSublayer(gradientLayer)
    }

    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }

    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}


final class InteractiveButton: UIButton {

    var hapticStyle: HapticStyle = .light

    enum HapticStyle {
        case light, medium, heavy, soft, selection, none
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInteraction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInteraction() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(
            self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func touchDown() {
        playHaptic()
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func touchUp() {
        UIView.animate(
            withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5
        ) {
            self.transform = .identity
        }
    }

    private func playHaptic() {
        switch hapticStyle {
        case .light: HapticManager.shared.lightTap()
        case .medium: HapticManager.shared.mediumTap()
        case .heavy: HapticManager.shared.heavyTap()
        case .soft: HapticManager.shared.softTap()
        case .selection: HapticManager.shared.selectionChanged()
        case .none: break
        }
    }
}
