class CustomerReviewModel {
  final String id;
  final String reviewerName;
  final String carTitle;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;
  final String? reply;
  final bool isCompensated;

  CustomerReviewModel({
    required this.id,
    required this.reviewerName,
    required this.carTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reply,
    this.isCompensated = false,
  });

  CustomerReviewModel copyWith({
    String? id,
    String? reviewerName,
    String? carTitle,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? reply,
    bool? isCompensated,
  }) {
    return CustomerReviewModel(
      id: id ?? this.id,
      reviewerName: reviewerName ?? this.reviewerName,
      carTitle: carTitle ?? this.carTitle,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      reply: reply ?? this.reply,
      isCompensated: isCompensated ?? this.isCompensated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerName': reviewerName,
      'carTitle': carTitle,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'reply': reply,
      'isCompensated': isCompensated,
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
      reply: json['reply'] as String?,
      isCompensated: json['isCompensated'] as bool? ?? false,
    );
  }
}
