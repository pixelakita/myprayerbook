class DailyGospel {
  final String reference;
  final String title;
  final String text;

  const DailyGospel({
    required this.reference,
    required this.title,
    required this.text,
  });

  factory DailyGospel.fromJson(Map<String, dynamic> json) {
    return DailyGospel(
      reference: json['reference'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reference': reference,
      'title': title,
      'text': text,
    };
  }
}
