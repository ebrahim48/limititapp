import DeviceActivity
import Foundation
import ManagedSettings

/// Wakes on the schedules `RuleScheduler` sets up and flips each rule's shield.
///
/// iOS calls this in its own process, often long after the app was last open,
/// so every decision is made from what `RuleStore` holds in the App Group.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard let (role, rule) = Self.rule(for: activity) else { return }

        switch (role, rule.kind) {
        case ("day", .dailyLimit):
            // A new day brings a fresh budget.
            RuleShield.clear(rule.id)

        case ("day", _):
            // delayOpening / maxOpens are shielded on every active day.
            RuleStore.setPauseStarted(nil, for: rule.id)
            if rule.isActiveDay() {
                RuleShield.apply(rule)
            } else {
                RuleShield.clear(rule.id)
            }

        case ("a", .timeBlock), ("b", .timeBlock):
            if RuleScheduler.isInsideBlock(rule) {
                RuleShield.apply(rule)
            }

        default:
            break
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard let (role, rule) = Self.rule(for: activity) else { return }

        switch role {
        case "a", "b":
            RuleShield.clear(rule.id)

        case "session":
            // The allowed open is over: the app goes back behind the shield.
            if rule.isActiveDay() {
                RuleShield.apply(rule)
            }

        default:
            break
        }
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        guard
            event == RuleScheduler.limitEvent,
            let (_, rule) = Self.rule(for: activity),
            rule.kind == .dailyLimit,
            rule.isActiveDay()
        else { return }

        RuleShield.apply(rule)
    }

    /// The active rule an activity belongs to. Rules deleted or switched off
    /// since the schedule was set are ignored.
    private static func rule(for activity: DeviceActivityName) -> (String, LimitRule)? {
        guard
            let (role, id) = RuleScheduler.parse(activity),
            let rule = RuleStore.rule(id: id),
            rule.isActive
        else { return nil }
        return (role, rule)
    }
}
