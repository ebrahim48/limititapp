import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

/// The user's protections, as the app and its Screen Time extensions share them.
///
/// Compiled into Runner and every extension (monitor, shield action, shield
/// configuration). iOS runs each of those as a separate process, so the only
/// common ground is the App Group's `UserDefaults`, and every rule is shielded
/// through its own named `ManagedSettingsStore` so one rule never lifts
/// another's block.
///
/// How each protection maps onto Apple's API:
///  - timeBlock: a repeating `DeviceActivitySchedule` per window; the monitor
///    shields at its start and lifts the shield at its end.
///  - dailyLimit: a whole-day schedule with a usage `DeviceActivityEvent`; the
///    monitor shields when the threshold is reached and lifts it at midnight.
///  - delayOpening / maxOpens: shielded all the time. The shield's button
///    (`ShieldActionExtension`) lets the app through for one session after
///    the pause, or while opens remain today.
enum LimitShared {
    static let appGroup = "group.com.limitit.digitalbalance"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    /// How long one allowed open lasts before the shield returns.
    /// DeviceActivity refuses intervals shorter than 15 minutes.
    static let sessionMinutes = 15
}

enum ProtectionKind: String, Codable {
    case delayOpening
    case dailyLimit
    case maxOpens
    case timeBlock
}

@available(iOS 16.0, *)
struct LimitRule: Codable {
    let id: String
    var kind: ProtectionKind
    var selection: FamilyActivitySelection
    var isActive: Bool
    /// "MON", "TUE", … as stored by Dart. Empty means every day.
    var activeDays: [String]
    var delaySeconds: Int
    var dailyLimitMinutes: Int
    var maxOpens: Int
    var blockStart: String?
    var blockEnd: String?
    var message: String?

    /// Everything that decides how the rule is scheduled. The selection is
    /// left out: it is fixed once the rule is created.
    func hasSameSchedule(as other: LimitRule) -> Bool {
        kind == other.kind
            && isActive == other.isActive
            && activeDays == other.activeDays
            && delaySeconds == other.delaySeconds
            && dailyLimitMinutes == other.dailyLimitMinutes
            && maxOpens == other.maxOpens
            && blockStart == other.blockStart
            && blockEnd == other.blockEnd
    }

    func isActiveDay(_ date: Date = Date()) -> Bool {
        guard !activeDays.isEmpty else { return true }
        let codes = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let weekday = Calendar.current.component(.weekday, from: date)
        return activeDays.contains(codes[weekday - 1])
    }

    func contains(_ token: ApplicationToken) -> Bool {
        selection.applicationTokens.contains(token)
    }

    func contains(_ token: ActivityCategoryToken) -> Bool {
        selection.categoryTokens.contains(token)
    }

    func contains(_ token: WebDomainToken) -> Bool {
        selection.webDomainTokens.contains(token)
    }
}

// MARK: - Storage

@available(iOS 16.0, *)
enum RuleStore {
    private static let rulesKey = "limitit.rules"

    static func all() -> [LimitRule] {
        guard
            let data = LimitShared.defaults.data(forKey: rulesKey),
            let rules = try? JSONDecoder().decode([LimitRule].self, from: data)
        else { return [] }
        return rules
    }

    static func save(_ rules: [LimitRule]) {
        guard let data = try? JSONEncoder().encode(rules) else { return }
        LimitShared.defaults.set(data, forKey: rulesKey)
    }

    static func rule(id: String) -> LimitRule? {
        all().first { $0.id == id }
    }

    /// The active rule that blocks this app, falling back to an inactive one
    /// so a stale shield still gets a sensible screen.
    static func rule(where matches: (LimitRule) -> Bool) -> LimitRule? {
        let candidates = all().filter(matches)
        return candidates.first { $0.isActive } ?? candidates.first
    }

    // Opens are counted per calendar day, so a new day starts from zero
    // without anyone having to reset it.
    static func opensToday(_ id: String) -> Int {
        guard LimitShared.defaults.string(forKey: "limitit.opens.day.\(id)") == today() else {
            return 0
        }
        return LimitShared.defaults.integer(forKey: "limitit.opens.count.\(id)")
    }

    static func recordOpen(_ id: String) {
        let count = opensToday(id) + 1
        LimitShared.defaults.set(today(), forKey: "limitit.opens.day.\(id)")
        LimitShared.defaults.set(count, forKey: "limitit.opens.count.\(id)")
    }

    static func pauseStarted(_ id: String) -> Date? {
        LimitShared.defaults.object(forKey: "limitit.pause.\(id)") as? Date
    }

    static func setPauseStarted(_ date: Date?, for id: String) {
        LimitShared.defaults.set(date, forKey: "limitit.pause.\(id)")
    }

    static func forgetState(_ id: String) {
        for key in ["limitit.opens.day.", "limitit.opens.count.", "limitit.pause."] {
            LimitShared.defaults.removeObject(forKey: key + id)
        }
    }

    private static func today() -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }
}

// MARK: - Shield

@available(iOS 16.0, *)
enum RuleShield {
    static func store(for id: String) -> ManagedSettingsStore {
        ManagedSettingsStore(named: ManagedSettingsStore.Name("limitit.rule.\(id)"))
    }

    static func apply(_ rule: LimitRule) {
        let store = store(for: rule.id)
        let selection = rule.selection
        store.shield.applications =
            selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories =
            selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        store.shield.webDomains =
            selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    static func clear(_ id: String) {
        store(for: id).clearAllSettings()
    }
}

// MARK: - Scheduling

/// Activity names are `limitit|<role>|<rule id>`:
///  - `day`: midnight to midnight; resets the day for every kind but timeBlock
///  - `a` / `b`: a timeBlock window (`b` only when the window crosses midnight)
///  - `session`: one allowed open of a delayOpening / maxOpens rule
@available(iOS 16.0, *)
enum RuleScheduler {
    static let limitEvent = DeviceActivityEvent.Name("limitit.limit")

    private static let center = DeviceActivityCenter()

    static func name(_ role: String, _ id: String) -> DeviceActivityName {
        DeviceActivityName("limitit|\(role)|\(id)")
    }

    /// `(role, rule id)` for one of our activity names.
    static func parse(_ activity: DeviceActivityName) -> (role: String, id: String)? {
        let parts = activity.rawValue.split(separator: "|", maxSplits: 2).map(String.init)
        guard parts.count == 3, parts[0] == "limitit" else { return nil }
        return (parts[1], parts[2])
    }

    /// Puts the rule's shield and schedules in the state it should be in now.
    static func start(_ rule: LimitRule) {
        stop(rule.id)
        guard rule.isActive else { return }

        switch rule.kind {
        case .dailyLimit:
            let event = DeviceActivityEvent(
                applications: rule.selection.applicationTokens,
                categories: rule.selection.categoryTokens,
                webDomains: rule.selection.webDomainTokens,
                threshold: DateComponents(minute: max(rule.dailyLimitMinutes, 1))
            )
            monitor(name("day", rule.id), wholeDay(), events: [limitEvent: event])

        case .timeBlock:
            guard
                let start = clock(rule.blockStart),
                let end = clock(rule.blockEnd)
            else { return }

            let startMinutes = start.hour! * 60 + start.minute!
            let endMinutes = end.hour! * 60 + end.minute!

            if startMinutes < endMinutes {
                monitor(name("a", rule.id), repeating(from: start, to: end))
            } else {
                // Crosses midnight (22:00–07:00): a schedule cannot, so split it.
                monitor(name("a", rule.id), repeating(from: start, to: endOfDay))
                monitor(name("b", rule.id), repeating(from: startOfDay, to: end))
            }

            if isInsideBlock(rule) {
                RuleShield.apply(rule)
            }

        case .delayOpening, .maxOpens:
            monitor(name("day", rule.id), wholeDay())
            if rule.isActiveDay() {
                RuleShield.apply(rule)
            }
        }
    }

    /// Lifts the rule's shield and stops everything scheduled for it.
    static func stop(_ id: String) {
        center.stopMonitoring(["day", "a", "b", "session"].map { name($0, id) })
        RuleShield.clear(id)
    }

    /// Lets the rule's apps through for one session. Returns `false` when iOS
    /// refused the schedule — the shield is then left in place, since nothing
    /// would bring it back.
    static func startSession(for rule: LimitRule) -> Bool {
        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(LimitShared.sessionMinutes * 60))
        let parts: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents(parts, from: now),
            intervalEnd: Calendar.current.dateComponents(parts, from: end),
            repeats: false
        )

        let session = name("session", rule.id)
        center.stopMonitoring([session])
        do {
            try center.startMonitoring(session, during: schedule)
        } catch {
            return false
        }
        RuleShield.clear(rule.id)
        return true
    }

    static func isInsideBlock(_ rule: LimitRule, at date: Date = Date()) -> Bool {
        guard
            rule.kind == .timeBlock,
            let start = clock(rule.blockStart),
            let end = clock(rule.blockEnd)
        else { return false }

        let now = Calendar.current.dateComponents([.hour, .minute], from: date)
        let current = now.hour! * 60 + now.minute!
        let from = start.hour! * 60 + start.minute!
        let to = end.hour! * 60 + end.minute!

        if from < to { return current >= from && current < to && rule.isActiveDay(date) }
        if current >= from { return rule.isActiveDay(date) }
        // After midnight the block belongs to the day it started on.
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        return current < to && rule.isActiveDay(yesterday)
    }

    private static let startOfDay = DateComponents(hour: 0, minute: 0, second: 0)
    private static let endOfDay = DateComponents(hour: 23, minute: 59, second: 59)

    private static func wholeDay() -> DeviceActivitySchedule {
        repeating(from: startOfDay, to: endOfDay)
    }

    private static func repeating(
        from start: DateComponents,
        to end: DateComponents
    ) -> DeviceActivitySchedule {
        DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: true)
    }

    private static func monitor(
        _ name: DeviceActivityName,
        _ schedule: DeviceActivitySchedule,
        events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
    ) {
        do {
            try center.startMonitoring(name, during: schedule, events: events)
        } catch {
            NSLog("LimitIt: could not monitor \(name.rawValue): \(error)")
        }
    }

    /// "22:00" → 22h 0m.
    private static func clock(_ text: String?) -> DateComponents? {
        guard let text else { return nil }
        let parts = text.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return DateComponents(hour: parts[0], minute: parts[1])
    }
}
