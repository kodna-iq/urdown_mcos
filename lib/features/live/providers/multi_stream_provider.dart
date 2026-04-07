import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stream_recording.dart';
import '../services/multi_stream_manager.dart';

// ─── Manager singleton provider ───────────────────────────────────────────────

final multiStreamManagerProvider = Provider<MultiStreamManager>((ref) {
  final manager = MultiStreamManager.instance;
  ref.onDispose(manager.disposeAll);
  return manager;
});

// ─── Live recordings list ─────────────────────────────────────────────────────

final recordingsProvider =
    StreamProvider<List<StreamRecording>>((ref) {
  final manager = ref.watch(multiStreamManagerProvider);
  return manager.recordingsStream;
});

// ─── Derived: active recording count ─────────────────────────────────────────

final activeRecordingCountProvider = Provider<int>((ref) {
  final recordings = ref.watch(recordingsProvider).valueOrNull ?? [];
  return recordings.where((r) => r.status.isActive).length;
});

// ─── Derived: total disk usage ────────────────────────────────────────────────

final totalRecordingSizeProvider = Provider<int>((ref) {
  final recordings = ref.watch(recordingsProvider).valueOrNull ?? [];
  return recordings.fold(0, (sum, r) => sum + r.sizeBytes);
});
