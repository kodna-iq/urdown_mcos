import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../main.dart';
import 'models/history_entry.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(isarProvider));
});

final historyProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.watchAll();
});

class HistoryRepository {
  final Isar _isar;

  HistoryRepository(this._isar);

  // Polling-based stream: re-queries every 500 ms, sorts in Dart.
  // Avoids .watch() and .sortBy().build().findAll() chain which require
  // the full Isar native change-notification support.
  Stream<List<HistoryEntry>> watchAll() async* {
    while (true) {
      try {
        final ids = await _isar.historyEntrys.where().idProperty().findAll();
        final all = await _isar.historyEntrys.getAll(ids);
        final entries = all.whereType<HistoryEntry>().toList();
        entries.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
        yield entries;
      } catch (_) {
        yield [];
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<List<HistoryEntry>> getAll() async {
    final ids = await _isar.historyEntrys.where().idProperty().findAll();
    final all = await _isar.historyEntrys.getAll(ids);
    final entries = all.whereType<HistoryEntry>().toList();
    entries.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return entries;
  }

  Future<List<HistoryEntry>> search(String query) async {
    final ids = await _isar.historyEntrys.where().idProperty().findAll();
    final all = await _isar.historyEntrys.getAll(ids);
    final entries = all.whereType<HistoryEntry>()
        .where((e) =>
            e.title.toLowerCase().contains(query.toLowerCase()) ||
            (e.channelName?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
    entries.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return entries;
  }

  Future<void> add(HistoryEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.historyEntrys.put(entry);
    });
  }

  Future<void> delete(String jobId) async {
    await _isar.writeTxn(() async {
      await _isar.historyEntrys.deleteByJobId(jobId);
    });
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.historyEntrys.clear();
    });
  }

  Future<int> get count async {
    final ids = await _isar.historyEntrys.where().idProperty().findAll();
    return ids.length;
  }
}
