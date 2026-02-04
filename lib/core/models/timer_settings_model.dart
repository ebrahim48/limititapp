import 'dart:convert';

/// Model to hold timer settings configuration
class TimerSettingsModel {
  final String preOpeningCountdown; // Countdown duration before opening app (e.g., '5 sec', '10 sec')
  final List<MotivationalQuote> motivationalQuotes; // List of motivational quotes
  final bool isEnabled; // Whether timer settings are enabled
  final DateTime createdAt;
  final DateTime updatedAt;

  TimerSettingsModel({
    required this.preOpeningCountdown,
    required this.motivationalQuotes,
    this.isEnabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'preOpeningCountdown': preOpeningCountdown,
      'motivationalQuotes': motivationalQuotes.map((quote) => quote.toJson()).toList(),
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TimerSettingsModel.fromJson(Map<String, dynamic> json) {
    return TimerSettingsModel(
      preOpeningCountdown: json['preOpeningCountdown'],
      motivationalQuotes: (json['motivationalQuotes'] as List)
          .map((quote) => MotivationalQuote.fromJson(quote))
          .toList(),
      isEnabled: json['isEnabled'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory TimerSettingsModel.fromJsonString(String jsonString) {
    return TimerSettingsModel.fromJson(jsonDecode(jsonString));
  }

  /// Copy with method
  TimerSettingsModel copyWith({
    String? preOpeningCountdown,
    List<MotivationalQuote>? motivationalQuotes,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimerSettingsModel(
      preOpeningCountdown: preOpeningCountdown ?? this.preOpeningCountdown,
      motivationalQuotes: motivationalQuotes ?? this.motivationalQuotes,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Always update 'updatedAt' when copying
    );
  }
}

/// Model for motivational quotes
class MotivationalQuote {
  final String text;
  final String author;
  final bool isHighlighted;

  MotivationalQuote({
    required this.text,
    required this.author,
    this.isHighlighted = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'isHighlighted': isHighlighted,
    };
  }

  /// Create from JSON
  factory MotivationalQuote.fromJson(Map<String, dynamic> json) {
    return MotivationalQuote(
      text: json['text'],
      author: json['author'],
      isHighlighted: json['isHighlighted'] ?? false,
    );
  }
}