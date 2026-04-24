import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/daily_gospel.dart';
import 'gospel_service.dart';

class RemoteGospelService implements GospelService {
  RemoteGospelService({
    required this.readingsUrl,
    this.fallbackAssetPath = 'assets/data/gospels.json',
    Duration? requestTimeout,
  }) : requestTimeout = requestTimeout ?? const Duration(seconds: 15);

  final String readingsUrl;
  final String fallbackAssetPath;
  final Duration requestTimeout;

  Map<String, DailyGospel>? _cache;

  @override
  Future<DailyGospel?> fetchGospel(DateTime date) async {
    _cache ??= await _loadEntries();
    return _cache![_formatDate(date)];
  }

  Future<Map<String, DailyGospel>> _loadEntries() async {
    try {
      final Uri uri = Uri.parse(readingsUrl);
      final http.Response response =
          await http.get(uri).timeout(requestTimeout);

      if (response.statusCode == 404) {
        debugPrint(
          'Remote gospel data returned 404. Falling back to $fallbackAssetPath.',
        );
        return _loadFallbackEntries();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String remoteJson = utf8.decode(response.bodyBytes);
        return _parseEntries(remoteJson);
      }

      throw Exception(
        'Unexpected HTTP ${response.statusCode} while downloading $readingsUrl',
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to download remote gospel data: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    return _loadFallbackEntries();
  }

  Future<Map<String, DailyGospel>> _loadFallbackEntries() async {
    try {
      final String fallbackJson = await rootBundle.loadString(fallbackAssetPath);
      return _parseEntries(fallbackJson);
    } catch (error, stackTrace) {
      debugPrint('Failed to load fallback gospel data: $error');
      debugPrintStack(stackTrace: stackTrace);
      return <String, DailyGospel>{};
    }
  }

  Map<String, DailyGospel> _parseEntries(String rawJson) {
    final Object? decoded = json.decode(rawJson);

    if (decoded is List) {
      return _parseReadingEntries(decoded);
    }

    if (decoded is Map) {
      return _parseLegacyEntries(Map<String, dynamic>.from(decoded));
    }

    throw const FormatException('Unsupported gospel JSON structure.');
  }

  Map<String, DailyGospel> _parseReadingEntries(List<dynamic> entries) {
    final Map<String, DailyGospel> result = <String, DailyGospel>{};

    for (final dynamic entry in entries) {
      if (entry is! Map) {
        continue;
      }

      final Map<String, dynamic> item = Map<String, dynamic>.from(entry);
      final String? date = _stringOrNull(item['date']);

      if (date == null) {
        continue;
      }

      try {
        result[date] = DailyGospel.fromReadingEntry(item);
      } catch (error, stackTrace) {
        debugPrint('Skipping invalid reading entry for $date: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    return result;
  }

  Map<String, DailyGospel> _parseLegacyEntries(Map<String, dynamic> entries) {
    return entries.map(
      (String date, dynamic value) => MapEntry(
        date,
        DailyGospel.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String? _stringOrNull(Object? value) {
    if (value is String) {
      final String normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }

    return null;
  }
}
