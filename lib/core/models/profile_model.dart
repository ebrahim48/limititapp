class GetProfileModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profilePicture;
  String? createdAt;

  GetProfileModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profilePicture,
    this.createdAt,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) {
    return GetProfileModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'],
    );
  }
}