import Foundation
import ManagedSettings

/// Handles the buttons on the block screen.
///
/// This is where delayOpening and maxOpens happen: their apps stay shielded,
/// and the primary button lets the user through for one session
/// (`LimitShared.sessionMinutes`) — after the pause has run, or while opens
/// remain today. dailyLimit and timeBlock only offer Close.
///
/// `.defer` asks iOS to show the shield again, which re-reads
/// `ShieldConfigurationExtension` and so updates its wording.
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(
            Self.respond(to: action, rule: RuleStore.rule { $0.contains(application) })
        )
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(
            Self.respond(to: action, rule: RuleStore.rule { $0.contains(webDomain) })
        )
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(
            Self.respond(to: action, rule: RuleStore.rule { $0.contains(category) })
        )
    }

    private static func respond(to action: ShieldAction, rule: LimitRule?) -> ShieldActionResponse {
        guard let rule, rule.isActive, action == .primaryButtonPressed else { return .close }

        switch rule.kind {
        case .delayOpening:
            return respondToPause(rule)

        case .maxOpens:
            guard RuleStore.opensToday(rule.id) < rule.maxOpens else { return .close }
            guard RuleScheduler.startSession(for: rule) else { return .close }
            RuleStore.recordOpen(rule.id)
            return .none

        case .dailyLimit, .timeBlock:
            return .close
        }
    }

    /// First tap starts the pause; a tap once it has run lets the app through.
    /// A pause left untouched for a couple of minutes starts over.
    private static func respondToPause(_ rule: LimitRule) -> ShieldActionResponse {
        let now = Date()
        let delay = TimeInterval(max(rule.delaySeconds, 1))

        if let started = RuleStore.pauseStarted(rule.id),
           now.timeIntervalSince(started) < delay + 120 {
            guard now.timeIntervalSince(started) >= delay else { return .defer }
            RuleStore.setPauseStarted(nil, for: rule.id)
            return RuleScheduler.startSession(for: rule) ? .none : .close
        }

        RuleStore.setPauseStarted(now, for: rule.id)
        return .defer
    }
}
