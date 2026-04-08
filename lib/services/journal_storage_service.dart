import 'dart:io';

import 'package:path_provider/path_provider.dart';

class JournalStorageService {
  Future<Directory> _getJournalDirectory() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory journalDir = Directory('${baseDir.path}/journals');

    if (!await journalDir.exists()) {
      await journalDir.create(recursive: true);
    }

    return journalDir;
  }

  String _formatDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<File> _getJournalFile(DateTime date) async {
    final Directory journalDir = await _getJournalDirectory();
    final String filename = 'journal_${_formatDate(date)}.txt';
    return File('${journalDir.path}/$filename');
  }

  Future<String> loadEntry(DateTime date) async {
    final File file = await _getJournalFile(date);

    if (!await file.exists()) {
      return '';
    }

    return file.readAsString();
  }

  Future<void> saveEntry({
    required DateTime date,
    required String content,
  }) async {
    final File file = await _getJournalFile(date);
    await file.writeAsString(content, flush: true);
  }

  Future<bool> hasEntry(DateTime date) async {
    final File file = await _getJournalFile(date);
    return file.exists();
  }

  Future<void> deleteEntry(DateTime date) async {
    final File file = await _getJournalFile(date);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
