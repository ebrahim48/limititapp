/// Stable identifiers for the limit options, so navigation logic never depends
/// on the (localized) title shown to the user.
enum LimitOptionId { screenTime, schedules, pinLock, detoxMode }

class LimitOption {
  final LimitOptionId id;
  final String title;
  final dynamic icon;
  final bool isPro;

  LimitOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.isPro,
  });
}
