class CourseInfoModel {
  final String id;
  final String title;
  final String subtitle;
  final String languageTag; // EN
  final String categoryTag; // FULL SYLLABUS BATCH
  final String bannerImageUrl;

  final List<CourseEducator> educators;

  final DateTime batchStartDate;
  final DateTime enrollmentEndDate;

  final CourseAbout about;
  final CourseStats stats;
  final CoursePricing pricing;

  final bool isEnrolled;

  CourseInfoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.languageTag,
    required this.categoryTag,
    required this.educators,
    required this.batchStartDate,
    required this.enrollmentEndDate,
    required this.about,
    required this.stats,
    required this.pricing,
    required this.isEnrolled,
    required this.bannerImageUrl,
  });

  factory CourseInfoModel.fromJson(Map<String, dynamic> json) {
    return CourseInfoModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      languageTag: json['languageTag'],
      categoryTag: json['categoryTag'],
      educators: (json['educators'] as List)
          .map((e) => CourseEducator.fromJson(e))
          .toList(),
      bannerImageUrl: json['bannerImageUrl'] ?? "",
      batchStartDate:
          DateTime.tryParse(json['batchStartDate'] ?? "") ?? DateTime.now(),
      enrollmentEndDate:
          DateTime.tryParse(json['enrollmentEndDate'] ?? "") ?? DateTime.now(),

      about: CourseAbout.fromJson(json['about']),
      stats: CourseStats.fromJson(json['stats']),
      pricing: CoursePricing.fromJson(json['pricing']),
      isEnrolled: json['isEnrolled'] ?? false,
    );
  }
}

class CourseEducator {
  final String id;
  final String name;
  final String imageUrl;

  CourseEducator({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CourseEducator.fromJson(Map<String, dynamic> json) {
    return CourseEducator(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}

class CourseAbout {
  final String description;
  final List<String> highlights;

  CourseAbout({required this.description, required this.highlights});

  factory CourseAbout.fromJson(Map<String, dynamic> json) {
    return CourseAbout(
      description: json['description'],
      highlights: List<String>.from(json['highlights']),
    );
  }
}

class CourseStats {
  final int liveClasses;
  final List<String> teachingLanguages;

  CourseStats({required this.liveClasses, required this.teachingLanguages});

  factory CourseStats.fromJson(Map<String, dynamic> json) {
    return CourseStats(
      liveClasses: json['liveClasses'],
      teachingLanguages: List<String>.from(json['teachingLanguages']),
    );
  }
}

class CoursePricing {
  final double price;
  final String currency;
  final bool isFree;

  CoursePricing({
    required this.price,
    required this.currency,
    required this.isFree,
  });

  factory CoursePricing.fromJson(Map<String, dynamic> json) {
    return CoursePricing(
      price: json['price'].toDouble(),
      currency: json['currency'],
      isFree: json['isFree'],
    );
  }
}