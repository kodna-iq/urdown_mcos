class AppConstants {
  AppConstants._();

  static const appName = 'UrDown';
  static const appVersion = '1.0.0';

  /// NOTE: This constant is the absolute hard cap for the UI slider max, NOT
  /// the runtime value. The runtime value always comes from AppSettings and is
  /// stored in SharedPreferences. Do NOT use this in DownloadManager — use
  /// settings.maxConcurrentDownloads instead.
  static const maxConcurrentDownloads = 5; // matches slider max in settings_page

  // Supported audio formats — ordered List so DropdownButtonFormField
  // has a stable, predictable item order. (Using Set caused random ordering
  // and potential assertion errors when defaultFormat was not the first item.)
  static const List<String> audioFormats = [
    'mp3',
    'aac',
    'flac',
    'wav',
    'm4a',
    'opus',
  ];

  // Supported video formats
  static const List<String> videoFormats = [
    'mp4',
    'mkv',
    'webm',
    'avi',
    'mov',
  ];

  // Default settings
  static const defaultBandwidthKBs = 0; // 0 = unlimited
  static const defaultMaxConcurrent = 3;
  static const defaultFormat = 'mp4'; // must be in videoFormats
  static const defaultResolution = '1080p'; // must be in resolutions

  // Retry config
  static const maxRetries = 3;
  static const retryBaseDelaySeconds = 2;

  // Progress throttle
  static const progressThrottleMs = 250;

  // Update check intervals
  static const updateCheckIntervalHours = 24;

  // Resolution options — must include defaultResolution
  static const List<String> resolutions = [
    '360p',
    '480p',
    '720p',
    '1080p',
    '1440p',
    '2160p',
    'Best',
  ];

  // Bandwidth limits in KB/s (0 = unlimited)
  static const Map<String, int> bandwidthOptions = {
    'Unlimited': 0,
    '512 KB/s': 512,
    '1 MB/s': 1024,
    '2 MB/s': 2048,
    '5 MB/s': 5120,
    '10 MB/s': 10240,
  };

  // ── Cookie site-file map ───────────────────────────────────────────────────
  // Single source of truth for domain → cookies filename mapping.
  // Any new platform (e.g. X/Twitter) must be added here only.
  static const Map<String, String> cookieSiteFiles = {
    'youtube.com':   'youtube_cookies.txt',
    'youtu.be':      'youtube_cookies.txt',
    'facebook.com':  'facebook_cookies.txt',
    'fb.watch':      'facebook_cookies.txt',
    'tiktok.com':    'tiktok_cookies.txt',
    'instagram.com': 'instagram_cookies.txt',
  };

  // Human-readable display names matching cookieSiteFiles keys (for Settings UI)
  static const Map<String, String> cookieSiteDisplayNames = {
    'YouTube':   'youtube_cookies.txt',
    'Facebook':  'facebook_cookies.txt',
    'TikTok':    'tiktok_cookies.txt',
    'Instagram': 'instagram_cookies.txt',
  };
}
