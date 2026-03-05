class AdModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final String createdAt;
  final String updatedAt;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class AdsResponseModel {
  final List<AdModel> ads;
  final PaginationModel pagination;

  AdsResponseModel({
    required this.ads,
    required this.pagination,
  });

  factory AdsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final adsList = data['ads'] as List<dynamic>;

    return AdsResponseModel(
      ads: adsList.map((ad) => AdModel.fromJson(ad)).toList(),
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
