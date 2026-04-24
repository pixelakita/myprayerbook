class DailyGospel {
  final String reference;
  final String title;
  final String text;

  const DailyGospel({
    required this.reference,
    required this.title,
    required this.text,
  });

  bool get hasDistinctTitle {
    return title.trim().isNotEmpty && title.trim() != reference.trim();
  }

  factory DailyGospel.fromJson(Map<String, dynamic> json) {
    return DailyGospel(
      reference: _stringValue(json['reference']),
      title: _stringValue(json['title']),
      text: _stringValue(json['text']),
    );
  }

  factory DailyGospel.fromReadingEntry(Map<String, dynamic> json) {
    final Map<String, dynamic> readings = _mapValue(json['readings'], 'readings');
    final Map<String, dynamic> gospel = _mapValue(readings['gospel'], 'readings.gospel');
    final List<dynamic> passages = _listValue(gospel['passages'], 'readings.gospel.passages');

    if (passages.isEmpty) {
      throw const FormatException('readings.gospel.passages is empty.');
    }

    final Map<String, dynamic> firstPassage =
        _mapValue(passages.first, 'readings.gospel.passages[0]');
    final Map<String, dynamic> response =
        _mapValue(firstPassage['response'], 'readings.gospel.passages[0].response');

    final String reference = _stringValue(
      response['reference'],
      fallback: _stringOrNull(gospel['original']) ?? _stringOrNull(firstPassage['original']) ?? '',
    );
    final String text = _stringValue(response['text']);
    final String title = _stringOrNull(firstPassage['label']) ??
        _stringOrNull(gospel['original']) ??
        reference;

    return DailyGospel(
      reference: reference,
      title: title,
      text: text,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reference': reference,
      'title': title,
      'text': text,
    };
  }

  static Map<String, dynamic> _mapValue(Object? value, String fieldName) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw FormatException('$fieldName is missing or is not an object.');
  }

  static List<dynamic> _listValue(Object? value, String fieldName) {
    if (value is List) {
      return value;
    }

    throw FormatException('$fieldName is missing or is not a list.');
  }

  static String _stringValue(Object? value, {String fallback = ''}) {
    final String? normalized = _stringOrNull(value);
    final String result = normalized ?? fallback;

    if (result.trim().isEmpty) {
      throw const FormatException('Expected a non-empty string value.');
    }

    return result;
  }

  static String? _stringOrNull(Object? value) {
    if (value is String) {
      final String normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }

    return null;
  }
}
