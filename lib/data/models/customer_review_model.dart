class CustomerReviewModel {
  final String id;
  final String reviewerName;
  final String carTitle;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;

  CustomerReviewModel({
    required this.id,
    required this.reviewerName,
    required this.carTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerName': reviewerName,
      'carTitle': carTitle,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerReviewModel.fromJson(Map<String, dynamic> json) {
    return CustomerReviewModel(
      id: json['id'] as String,
      reviewerName: json['reviewerName'] as String,
      carTitle: json['carTitle'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
