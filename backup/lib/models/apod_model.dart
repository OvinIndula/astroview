class ApodImage {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String? hdUrl;
  final String? copyright;
  final String? mediaType;
  final String? serviceVersion;

  ApodImage({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    this.hdUrl,
    this.copyright,
    this.mediaType,
    this.serviceVersion,
  });

  factory ApodImage.fromJson(Map<String, dynamic> json) {
    return ApodImage(
      title: json['title'] ?? 'Unknown',
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      hdUrl: json['hdurl'],
      copyright: json['copyright'],
      mediaType: json['media_type'],
      serviceVersion: json['service_version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'explanation': explanation,
      'url': url,
      'hdurl': hdUrl,
      'copyright': copyright,
      'media_type': mediaType,
      'service_version': serviceVersion,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApodImage &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          date == other.date;

  @override
  int get hashCode => title.hashCode ^ date.hashCode;
}