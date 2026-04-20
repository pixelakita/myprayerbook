import '../models/daily_gospel.dart';

/// Abstract gospel service.
/// Swap [LocalGospelService] for a network implementation
/// by changing one line in main.dart.
abstract class GospelService {
  /// Returns the gospel for [date], or null if not found.
  Future<DailyGospel?> fetchGospel(DateTime date);
}
