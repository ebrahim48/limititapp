class PlanModel {
  final String id;
  final String name;
  final String type;
  final int duration;
  final double price;
  final List<String> benefits;
  final PlanLimits limits;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.price,
    required this.benefits,
    required this.limits,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      duration: json['duration'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      benefits: json['benefits'] != null 
          ? List<String>.from(json['benefits']) 
          : [],
      limits: PlanLimits.fromJson(json['limits'] ?? {}),
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'duration': duration,
      'price': price,
      'benefits': benefits,
      'limits': limits.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PlanLimits {
  final int maxApps;
  final int dailyLimit;

  PlanLimits({
    required this.maxApps,
    required this.dailyLimit,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      maxApps: json['maxApps'] ?? 0,
      dailyLimit: json['dailyLimit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxApps': maxApps,
      'dailyLimit': dailyLimit,
    };
  }
}
