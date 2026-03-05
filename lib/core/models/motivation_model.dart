class MotivationModel {
  final String id;
  final String author;
  final String content;
  final String createdAt;
  final String updatedAt;

  MotivationModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MotivationModel.fromJson(Map<String, dynamic> json) {
    return MotivationModel(
      id: json['_id'] ?? '',
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class MotivationResponseModel {
  final List<MotivationModel> motivations;
  final PaginationModel pagination;

  MotivationResponseModel({
    required this.motivations,
    required this.pagination,
  });

  factory MotivationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final motivationsList = data['motivations'] as List<dynamic>;
    
    return MotivationResponseModel(
      motivations: motivationsList
          .map((motivation) => MotivationModel.fromJson(motivation))
          .toList(),
      pagination: PaginationModel.fromJson(data['pagination']),
    );
  }
}

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
