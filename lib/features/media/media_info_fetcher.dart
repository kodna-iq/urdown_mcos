import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cli/ytdlp_runner.dart';
import '../download/models/media_info.dart';
import '../../services/url_sanitizer.dart';

final mediaInfoFetcherProvider = Provider<MediaInfoFetcher>((ref) {
  return MediaInfoFetcher();
});

class MediaInfoFetcher {
  Future<MediaInfo> fetch(String rawUrl) async {
    final url = UrlSanitizer.sanitize(rawUrl);
    return YtDlpRunner.fetchInfo(url);
  }
}

final mediaInfoProvider =
    FutureProvider.autoDispose.family<MediaInfo, String>((ref, url) async {
  final fetcher = ref.watch(mediaInfoFetcherProvider);
  return fetcher.fetch(url);
});
