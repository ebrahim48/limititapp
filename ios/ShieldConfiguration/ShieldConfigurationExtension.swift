import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Draws the screen iOS shows when a blocked app is opened.
///
/// Apple fixes the layout (icon, title, subtitle, buttons); we pick the wording
/// for the rule that blocked the app. The buttons' behaviour lives in
/// `ShieldActionExtension`.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        configuration(
            for: application.localizedDisplayName,
            rule: application.token.flatMap { token in RuleStore.rule { $0.contains(token) } }
        )
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        let byApp = application.token.flatMap { token in RuleStore.rule { $0.contains(token) } }
        let byCategory = category.token.flatMap { token in RuleStore.rule { $0.contains(token) } }
        return configuration(for: application.localizedDisplayName, rule: byApp ?? byCategory)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        configuration(
            for: webDomain.domain,
            rule: webDomain.token.flatMap { token in RuleStore.rule { $0.contains(token) } }
        )
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        let byDomain = webDomain.token.flatMap { token in RuleStore.rule { $0.contains(token) } }
        let byCategory = category.token.flatMap { token in RuleStore.rule { $0.contains(token) } }
        return configuration(for: webDomain.domain, rule: byDomain ?? byCategory)
    }

    private func configuration(for name: String?, rule: LimitRule?) -> ShieldConfiguration {
        let appName = name ?? "this app"

        guard let rule else {
            return shield(
                title: "Restricted",
                subtitle: "You cannot use \(appName) because it is restricted.",
                primary: "OK"
            )
        }

        switch rule.kind {
        case .delayOpening:
            let delay = rule.delaySeconds
            if let started = RuleStore.pauseStarted(rule.id) {
                let remaining = delay - Int(Date().timeIntervalSince(started))
                if remaining <= 0 {
                    return shield(
                        title: "Still want to open it?",
                        subtitle: rule.message ?? "Your pause is over.",
                        primary: "Open \(appName)",
                        secondary: "Close"
                    )
                }
                return shield(
                    title: "Breathe…",
                    subtitle: "Wait \(remaining)s, then tap below to open \(appName).",
                    primary: "Open after pause",
                    secondary: "Close"
                )
            }
            return shield(
                title: "Take a mindful pause",
                subtitle: rule.message
                    ?? "Tap Start, wait \(delay) seconds, then tap again to open \(appName).",
                primary: "Start \(delay)s pause",
                secondary: "Close"
            )

        case .maxOpens:
            let left = rule.maxOpens - RuleStore.opensToday(rule.id)
            if left <= 0 {
                return shield(
                    title: "Opening limit reached",
                    subtitle: rule.message
                        ?? "You've opened \(appName) \(rule.maxOpens) times today. See you tomorrow.",
                    primary: "Close"
                )
            }
            return shield(
                title: "\(left) of \(rule.maxOpens) opens left today",
                subtitle: rule.message
                    ?? "Each open gives you \(LimitShared.sessionMinutes) minutes in \(appName).",
                primary: "Open \(appName)",
                secondary: "Close"
            )

        case .dailyLimit:
            return shield(
                title: "Daily limit reached",
                subtitle: rule.message
                    ?? "You've used \(appName) for \(Self.duration(rule.dailyLimitMinutes)) today.",
                primary: "Close"
            )

        case .timeBlock:
            return shield(
                title: "Blocked right now",
                subtitle: rule.message
                    ?? "\(appName) is blocked \(rule.blockStart ?? "")–\(rule.blockEnd ?? "").",
                primary: "Close"
            )
        }
    }

    private func shield(
        title: String,
        subtitle: String,
        primary: String,
        secondary: String? = nil
    ) -> ShieldConfiguration {
        ShieldConfiguration(
            icon: UIImage(named: "ShieldIcon"),
            title: ShieldConfiguration.Label(text: title, color: .label),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: primary, color: .white),
            primaryButtonBackgroundColor: .systemGreen,
            secondaryButtonLabel: secondary.map {
                ShieldConfiguration.Label(text: $0, color: .systemGreen)
            }
        )
    }

    private static func duration(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h == 0 { return "\(m)m" }
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
}
