// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_service.dart';

// ─── AppStrings: all UI text in one place ─────────────────────────────────
// Usage: final s = ref.watch(stringsProvider);  →  s.settings
// Or in a Widget: AppStrings.of(context).settings
// ──────────────────────────────────────────────────────────────────────────

class AppStrings {
  const AppStrings(this._code);
  final String _code;

  // ── Shortcut ────────────────────────────────────────────────────────────
  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings(locale.languageCode);
  }

  // ── Navigation ──────────────────────────────────────────────────────────
  String get home          => _t({'en':'Home','ar':'الرئيسية','zh':'主页','es':'Inicio','ru':'Главная','ku':'سەرەکی'});
  String get queue         => _t({'en':'Queue','ar':'قائمة التنزيل','zh':'队列','es':'Cola','ru':'Очередь','ku':'ڕیز'});
  String get history       => _t({'en':'History','ar':'السجل','zh':'历史','es':'Historial','ru':'История','ku':'مێژوو'});
  String get settings      => _t({'en':'Settings','ar':'الإعدادات','zh':'设置','es':'Ajustes','ru':'Настройки','ku':'ڕێکخستنەکان'});

  // ── Dashboard ───────────────────────────────────────────────────────────
  String get dashboard          => _t({'en':'Dashboard','ar':'لوحة التحكم','zh':'控制面板','es':'Panel','ru':'Панель','ku':'داشبۆرد'});
  String get activeDownloads    => _t({'en':'Active Downloads','ar':'التنزيلات النشطة','zh':'正在下载','es':'Descargas activas','ru':'Активные загрузки','ku':'داگرتنە چالاکەکان'});
  String get recentlyCompleted  => _t({'en':'Recently Completed','ar':'اكتملت مؤخراً','zh':'最近完成','es':'Completado recientemente','ru':'Недавно завершено','ku':'بە تازەگی تەواوبوو'});
  String get viewAll            => _t({'en':'View all','ar':'عرض الكل','zh':'查看全部','es':'Ver todo','ru':'Все','ku':'هەمووی ببینە'});
  String get viewHistory        => _t({'en':'View history','ar':'عرض السجل','zh':'查看历史','es':'Ver historial','ru':'История','ku':'مێژوو ببینە'});
  String get active             => _t({'en':'Active','ar':'نشط','zh':'活动','es':'Activo','ru':'Активно','ku':'چالاک'});
  String get completed          => _t({'en':'Completed','ar':'مكتمل','zh':'已完成','es':'Completado','ru':'Завершено','ku':'تەواوبوو'});
  String get failed             => _t({'en':'Failed','ar':'فشل','zh':'失败','es':'Fallido','ru':'Ошибка','ku':'شکستهێنا'});
  String get total              => _t({'en':'Total','ar':'الإجمالي','zh':'总计','es':'Total','ru':'Всего','ku':'کۆ'});

  // ── New Download ─────────────────────────────────────────────────────────
  String get newDownload        => _t({'en':'New Download','ar':'تنزيل جديد','zh':'新建下载','es':'Nueva descarga','ru':'Новая загрузка','ku':'داگرتنی نوێ'});
  String get downloadAVideo     => _t({'en':'Download a Video','ar':'تنزيل فيديو','zh':'下载视频','es':'Descargar video','ru':'Загрузить видео','ku':'ڤیدیۆ داگرە'});
  String get openURL            => _t({'en':'Open URL','ar':'أدخل الرابط','zh':'输入链接','es':'URL','ru':'Введите URL','ku':'بەستەر بنووسە'});
  String get fetch              => _t({'en':'Fetch','ar':'جلب','zh':'获取','es':'Obtener','ru':'Получить','ku':'وەرگرە'});
  String get format             => _t({'en':'Format','ar':'الصيغة','zh':'格式','es':'Formato','ru':'Формат','ku':'فۆرمات'});
  String get resolution         => _t({'en':'Resolution','ar':'الجودة','zh':'分辨率','es':'Resolución','ru':'Разрешение','ku':'چارەزایی'});
  String get embedThumbnail     => _t({'en':'Embed Thumbnail','ar':'تضمين الصورة المصغرة','zh':'嵌入缩略图','es':'Insertar miniatura','ru':'Вставить миниатюру','ku':'وێنەی بچووک دابگرە'});
  String get addCoverArt        => _t({'en':'Add cover art to the file','ar':'إضافة غلاف للملف','zh':'添加封面','es':'Añadir portada','ru':'Добавить обложку','ku':'پووشپەڕ زیاد بکە'});
  String get extractAudio       => _t({'en':'Extract Audio Only','ar':'استخراج الصوت فقط','zh':'仅提取音频','es':'Solo audio','ru':'Только аудио','ku':'تەنها دەنگ'});
  String get saveAsAudio        => _t({'en':'Save as audio file only','ar':'حفظ كملف صوتي فقط','zh':'仅保存为音频','es':'Guardar solo audio','ru':'Только аудио файл','ku':'تەنها وەک فایلی دەنگ پاشەکەوت بکە'});
  String get downloadSubtitles  => _t({'en':'Download Subtitles','ar':'تنزيل الترجمة','zh':'下载字幕','es':'Descargar subtítulos','ru':'Скачать субтитры','ku':'ژێرنووس داگرە'});
  String get downloadSubtitleTracks => _t({'en':'Download available subtitle tracks','ar':'تنزيل مسارات الترجمة المتاحة','zh':'下载可用字幕轨道','es':'Descargar pistas de subtítulos','ru':'Загрузить субтитры','ku':'مەسارەکانی ژێرنووس داگرە'});
  String get startDownload      => _t({'en':'Start Download','ar':'بدء التنزيل','zh':'开始下载','es':'Iniciar descarga','ru':'Начать загрузку','ku':'داگرتن بەڕێوەبەرە'});
  String get adding             => _t({'en':'Adding...','ar':'جارٍ الإضافة...','zh':'添加中...','es':'Añadiendo...','ru':'Добавление...','ku':'زیادکردن...'});
  String get importTxt          => _t({'en':'Import .txt','ar':'استيراد .txt','zh':'导入 .txt','es':'Importar .txt','ru':'Импорт .txt','ku':'هاوردەکردنی .txt'});
  String get failedToStart      => _t({'en':'Failed to start download','ar':'فشل بدء التنزيل','zh':'下载启动失败','es':'Error al iniciar descarga','ru':'Ошибка запуска загрузки','ku':'داگرتن دەستپێنەکرد'});
  String get outputOptions      => _t({'en':'Output Options','ar':'خيارات الإخراج','zh':'输出选项','es':'Opciones de salida','ru':'Параметры вывода','ku':'هەڵبژاردنەکانی دەرکەوتن'});
  String get options            => _t({'en':'Options','ar':'الخيارات','zh':'选项','es':'Opciones','ru':'Параметры','ku':'هەڵبژاردنەکان'});
  String get videoURL           => _t({'en':'Video URL','ar':'رابط الفيديو','zh':'视频链接','es':'URL del video','ru':'Ссылка на видео','ku':'بەستەری ڤیدیۆ'});
  String get singleURL          => _t({'en':'Single','ar':'رابط واحد','zh':'单个','es':'Individual','ru':'Одиночный','ku':'تەک'});
  String get bulk               => _t({'en':'Bulk','ar':'متعدد','zh':'批量','es':'Masivo','ru':'Массовый','ku':'کۆمەڵ'});
  String get bulkUrls           => _t({'en':'Bulk URLs','ar':'روابط متعددة','zh':'批量链接','es':'URLs masivos','ru':'Массовые ссылки','ku':'بەستەرە کۆمەڵەکان'});
  String get subtitleLanguage   => _t({'en':'Subtitle Language','ar':'لغة الترجمة','zh':'字幕语言','es':'Idioma de subtítulos','ru':'Язык субтитров','ku':'زمانی ژێرنووس'});
  String get subtitleLangHint   => _t({'en':'e.g. en, ar, fr','ar':'مثال: ar, en, fr','zh':'如: zh, en, fr','es':'Ej: es, en, fr','ru':'напр: ru, en, ar','ku':'نموونە: ku, en, ar'});

  // ── Queue ────────────────────────────────────────────────────────────────
  String get cancel             => _t({'en':'Cancel','ar':'إلغاء','zh':'取消','es':'Cancelar','ru':'Отмена','ku':'پاشگەزبوونەوە'});
  String get remove             => _t({'en':'Remove','ar':'حذف','zh':'删除','es':'Eliminar','ru':'Удалить','ku':'لابردن'});
  String get removeFromList     => _t({'en':'Remove from list only','ar':'الإزالة من القائمة فقط','zh':'仅从列表删除','es':'Solo de la lista','ru':'Только из списка','ku':'تەنها لە لیستەوە لابدە'});
  String get deleteFilesToo     => _t({'en':'Delete files too','ar':'حذف الملفات أيضاً','zh':'同时删除文件','es':'Borrar archivos también','ru':'Удалить файлы тоже','ku':'فایلەکانیش بسڕەوە'});
  String get clearCompleted     => _t({'en':'Clear Completed','ar':'مسح المكتملة','zh':'清除已完成','es':'Limpiar completados','ru':'Очистить завершённые','ku':'تەواوبووەکان پاک بکەرەوە'});
  String get clearAll           => _t({'en':'Clear All','ar':'مسح الكل','zh':'全部清除','es':'Limpiar todo','ru':'Очистить всё','ku':'هەمووی پاک بکەرەوە'});
  String get clear              => _t({'en':'Clear','ar':'مسح','zh':'清除','es':'Limpiar','ru':'Очистить','ku':'پاک بکەرەوە'});
  String get deleteTitle        => _t({'en':'Delete','ar':'حذف','zh':'删除','es':'Eliminar','ru':'Удалить','ku':'سڕینەوە'});
  String get deleteQuestion     => _t({'en':'What would you like to delete?','ar':'ما الذي تريد حذفه؟','zh':'您要删除什么？','es':'¿Qué deseas eliminar?','ru':'Что вы хотите удалить?','ku':'چیت دەوێ بسڕیتەوە؟'});
  String get deleteAll          => _t({'en':'Delete All','ar':'حذف الكل','zh':'删除全部','es':'Eliminar todo','ru':'Удалить всё','ku':'هەمووی بسڕەوە'});
  String get deleteAllQuestion  => _t({'en':'Delete all downloads?','ar':'هل تريد حذف جميع التنزيلات؟','zh':'删除所有下载？','es':'¿Eliminar todas las descargas?','ru':'Удалить все загрузки?','ku':'هەموو داگرتنەکان بسڕیتەوە؟'});
  String get add                => _t({'en':'Add','ar':'إضافة','zh':'添加','es':'Añadir','ru':'Добавить','ku':'زیادکردن'});
  String get download           => _t({'en':'Download','ar':'تنزيل','zh':'下载','es':'Descargar','ru':'Загрузить','ku':'داگرتن'});
  String get pause              => _t({'en':'Pause','ar':'إيقاف مؤقت','zh':'暂停','es':'Pausar','ru':'Пауза','ku':'ڕاگرتن'});
  String get resume             => _t({'en':'Resume','ar':'استئناف','zh':'继续','es':'Reanudar','ru':'Продолжить','ku':'بەردەوامبوون'});
  String get retry              => _t({'en':'Retry','ar':'إعادة المحاولة','zh':'重试','es':'Reintentar','ru':'Повторить','ku':'دووبارەکەشتن'});
  String get play               => _t({'en':'Play','ar':'تشغيل','zh':'播放','es':'Reproducir','ru':'Воспроизвести','ku':'لێدان'});
  String get showFile           => _t({'en':'Show File','ar':'عرض الملف','zh':'显示文件','es':'Mostrar archivo','ru':'Показать файл','ku':'فایل پیشان بدە'});

  // ── Status chips ─────────────────────────────────────────────────────────
  String get statusDownloading  => _t({'en':'Downloading','ar':'جارٍ التنزيل','zh':'下载中','es':'Descargando','ru':'Загрузка','ku':'داگیردەکرێت'});
  String get statusQueued       => _t({'en':'Queued','ar':'في الانتظار','zh':'排队中','es':'En cola','ru':'В очереди','ku':'ڕیزکراو'});
  String get statusPaused       => _t({'en':'Paused','ar':'متوقف','zh':'已暂停','es':'Pausado','ru':'Пауза','ku':'ڕاگیراو'});
  String get statusDone         => _t({'en':'Done','ar':'مكتمل','zh':'完成','es':'Listo','ru':'Готово','ku':'تەواو'});
  String get statusFailed       => _t({'en':'Failed','ar':'فشل','zh':'失败','es':'Fallido','ru':'Ошибка','ku':'شکستهێنا'});
  String get statusCancelled    => _t({'en':'Cancelled','ar':'ملغى','zh':'已取消','es':'Cancelado','ru':'Отменено','ku':'هەڵوەشاندرا'});

  // ── History ──────────────────────────────────────────────────────────────
  String get clearHistory       => _t({'en':'Clear History','ar':'مسح السجل','zh':'清除历史','es':'Borrar historial','ru':'Очистить историю','ku':'مێژوو پاک بکەرەوە'});
  String get clearHistoryTitle  => _t({'en':'Clear History','ar':'مسح السجل','zh':'清除历史','es':'Borrar historial','ru':'Очистить историю','ku':'مێژوو پاک بکەرەوە'});
  String get clearHistoryBody   => _t({'en':'Remove all history entries?','ar':'إزالة جميع سجلات التنزيل؟','zh':'删除所有历史记录？','es':'¿Eliminar todo el historial?','ru':'Удалить все записи истории?','ku':'هەموو تۆمارەکانی مێژوو لابدە؟'});
  String get searchHistory      => _t({'en':'Search history…','ar':'ابحث في السجل…','zh':'搜索历史…','es':'Buscar historial…','ru':'Поиск в истории…','ku':'مێژوو بگەڕێ…'});
  String get noHistoryYet       => _t({'en':'No history yet','ar':'لا يوجد سجل بعد','zh':'暂无历史','es':'Sin historial aún','ru':'История пуста','ku':'هێشتا مێژوو نییە'});
  String get noResultsFound     => _t({'en':'No results found','ar':'لا توجد نتائج','zh':'未找到结果','es':'Sin resultados','ru':'Ничего не найдено','ku':'هیچ ئەنجامێک نەدۆزرایەوە'});
  String get openInBrowser      => _t({'en':'Open in browser','ar':'فتح في المتصفح','zh':'在浏览器中打开','es':'Abrir en navegador','ru':'Открыть в браузере','ku':'لە وێبگەڕەکەوە بکەرەوە'});

  // ── Settings ─────────────────────────────────────────────────────────────
  String get behavior           => _t({'en':'Behavior','ar':'السلوك','zh':'行为','es':'Comportamiento','ru':'Поведение','ku':'ڕەفتار'});
  String get language           => _t({'en':'Language','ar':'اللغة','zh':'语言','es':'Idioma','ru':'Язык','ku':'زمان'});
  String get appearance         => _t({'en':'Appearance','ar':'المظهر','zh':'外观','es':'Apariencia','ru':'Внешний вид','ku':'ڕووکار'});
  String get accountsCookies    => _t({'en':'Accounts & Cookies','ar':'الحسابات والكوكيز','zh':'账户与Cookies','es':'Cuentas y Cookies','ru':'Аккаунты и куки','ku':'هەژمار و کووکیز'});
  String get about              => _t({'en':'About','ar':'حول','zh':'关于','es':'Acerca de','ru':'О программе','ku':'دەربارە'});
  String get embedThumbnailByDefault => _t({'en':'Embed Thumbnail by Default','ar':'تضمين الصورة المصغرة افتراضياً','zh':'默认嵌入缩略图','es':'Miniatura por defecto','ru':'Вставлять миниатюру по умолчанию','ku':'بە خۆکاری وێنەی بچووک دابگرە'});
  String get addMetadata        => _t({'en':'Add Metadata','ar':'إضافة بيانات وصفية','zh':'添加元数据','es':'Añadir metadatos','ru':'Добавить метаданные','ku':'زانیاری زیاد بکە'});
  String get clipboardMonitor   => _t({'en':'Clipboard Monitor','ar':'مراقب الحافظة','zh':'剪贴板监控','es':'Monitor portapapeles','ru':'Монитор буфера','ku':'چاودێری کلیپبۆرد'});
  String get clipboardSubtitle  => _t({'en':'Auto-detect URLs copied to clipboard','ar':'كشف الروابط المنسوخة تلقائياً','zh':'自动检测剪贴板链接','es':'Detectar URLs copiadas','ru':'Автообнаружение URL в буфере','ku':'بە خۆکاری بەستەرەکانی لە کلیپبۆرد دۆزەرەوە'});
  String get notifications      => _t({'en':'Notifications','ar':'الإشعارات','zh':'通知','es':'Notificaciones','ru':'Уведомления','ku':'ئاگادارکردنەوەکان'});
  String get appLanguage        => _t({'en':'App Language','ar':'لغة التطبيق','zh':'应用语言','es':'Idioma de la app','ru':'Язык приложения','ku':'زمانی ئەپ'});
  String get theme              => _t({'en':'Theme','ar':'السمة','zh':'主题','es':'Tema','ru':'Тема','ku':'ڕووکار'});
  String get themeDark          => _t({'en':'Dark','ar':'داكن','zh':'深色','es':'Oscuro','ru':'Тёмная','ku':'تاریک'});
  String get themeLight         => _t({'en':'Light','ar':'فاتح','zh':'浅色','es':'Claro','ru':'Светлая','ku':'ڕووناک'});
  String get themeSystem        => _t({'en':'System','ar':'النظام','zh':'跟随系统','es':'Sistema','ru':'Системная','ku':'سیستەم'});
  String get manageCookies      => _t({'en':'Manage Cookies','ar':'إدارة الكوكيز','zh':'管理Cookies','es':'Gestionar cookies','ru':'Управление куки','ku':'کووکیز بەڕێوەببرە'});
  String get serverCookies      => _t({'en':'Server Cookies','ar':'كوكيز الخادم','zh':'服务器Cookies','es':'Cookies del servidor','ru':'Серверные куки','ku':'کووکیزی سێرڤەر'});
  String get outputDirectory    => _t({'en':'Output Directory','ar':'مجلد الحفظ','zh':'保存目录','es':'Directorio de salida','ru':'Папка сохранения','ku':'پوختەی پاشەکەوتکردن'});
  String get defaultDownloads   => _t({'en':'Default (Downloads/UrDown)','ar':'افتراضي (Downloads/UrDown)','zh':'默认 (Downloads/UrDown)','es':'Predeterminado','ru':'По умолчанию','ku':'بنەڕەت (Downloads/UrDown)'});
  String get maxConcurrent      => _t({'en':'Max Concurrent Downloads','ar':'أقصى تنزيلات متزامنة','zh':'最大并发下载数','es':'Máximo simultáneo','ru':'Макс. параллельных загрузок','ku':'زۆرترین داگرتنی ئەکتیڤ'});
  String get bandwidthLimit     => _t({'en':'Bandwidth Limit','ar':'حد سرعة الإنترنت','zh':'带宽限制','es':'Límite de ancho de banda','ru':'Ограничение скорости','ku':'سنووری پانییەی تۆڕ'});
  String get defaultQuality     => _t({'en':'Default Quality','ar':'الجودة الافتراضية','zh':'默认质量','es':'Calidad predeterminada','ru':'Качество по умолчанию','ku':'کوالیتی بنەڕەت'});
  String get defaultFormat      => _t({'en':'Default Format','ar':'الصيغة الافتراضية','zh':'默认格式','es':'Formato predeterminado','ru':'Формат по умолчанию','ku':'فۆرماتی بنەڕەت'});
  String get defaultResolution  => _t({'en':'Default Resolution','ar':'الجودة الافتراضية','zh':'默认分辨率','es':'Resolución predeterminada','ru':'Разрешение по умолчанию','ku':'چارەزایی بنەڕەت'});
  String get appVersion         => _t({'en':'App version','ar':'إصدار التطبيق','zh':'应用版本','es':'Versión','ru':'Версия','ku':'وەشانی ئەپ'});
  String get checkUpdatesStartup => _t({'en':'Check for updates on startup','ar':'التحقق من التحديثات عند البدء','zh':'启动时检查更新','es':'Verificar actualizaciones al inicio','ru':'Проверять обновления при запуске','ku':'لە دەستپێکردن نوێکردنەوە بپشکنە'});
  String get checkForUpdates    => _t({'en':'Check for Updates','ar':'التحقق من التحديثات','zh':'检查更新','es':'Buscar actualizaciones','ru':'Проверить обновления','ku':'نوێکردنەوە بپشکنە'});
  String get currentVersion     => _t({'en':'Current version','ar':'الإصدار الحالي','zh':'当前版本','es':'Versión actual','ru':'Текущая версия','ku':'وەشانی ئێستا'});
  String get ytdlpVersion       => _t({'en':'yt-dlp version','ar':'إصدار yt-dlp','zh':'yt-dlp 版本','es':'Versión yt-dlp','ru':'Версия yt-dlp','ku':'وەشانی yt-dlp'});
  String get ffmpegVersion      => _t({'en':'FFmpeg version','ar':'إصدار FFmpeg','zh':'FFmpeg 版本','es':'Versión FFmpeg','ru':'Версия FFmpeg','ku':'وەشانی FFmpeg'});
  String get notFound           => _t({'en':'Not found','ar':'غير موجود','zh':'未找到','es':'No encontrado','ru':'Не найден','ku':'نەدۆزرایەوە'});
  String get upToDate           => _t({'en':'You are on the latest version!','ar':'أنت تستخدم أحدث إصدار!','zh':'已是最新版本！','es':'¡Tienes la última versión!','ru':'У вас последняя версия!','ku':'تۆ لەسەر نوێترین وەشانی!'});
  String get updateCheckFailed  => _t({'en':'Update check failed','ar':'فشل التحقق من التحديث','zh':'检查更新失败','es':'Error al verificar','ru':'Ошибка проверки обновлений','ku':'پشکنینی نوێکردنەوە شکستی هێنا'});
  String get downloads          => _t({'en':'Downloads','ar':'التنزيلات','zh':'下载','es':'Descargas','ru':'Загрузки','ku':'داگرتنەکان'});
  String get error              => _t({'en':'Error','ar':'خطأ','zh':'错误','es':'Error','ru':'Ошибка','ku':'هەڵە'});

  // ── Dashboard extra ──────────────────────────────────────────────────────
  String get manageDownloads    => _t({'en':'Manage your downloads','ar':'إدارة التنزيلات الخاصة بك','zh':'管理您的下载','es':'Gestiona tus descargas','ru':'Управление загрузками','ku':'داگرتنەکانت بەڕێوەببرە'});
  String get pasteUrlHint       => _t({'en':'Paste a URL from YouTube, TikTok, or 1000+ sites','ar':'الصق رابطاً من يوتيوب أو تيك توك أو أكثر من 1000 موقع','zh':'粘贴来自YouTube、TikTok等1000+网站的链接','es':'Pega un URL de YouTube, TikTok y más de 1000 sitios','ru':'Вставьте URL с YouTube, TikTok или 1000+ сайтов','ku':'بەستەرێک لە یووتیووب، تیکتۆک یان ١٠٠٠+ مالپەڕ بچەسپێنە'});
  String get linkDetected       => _t({'en':'Link detected in clipboard','ar':'تم اكتشاف رابط في الحافظة','zh':'剪贴板中检测到链接','es':'Enlace detectado en portapapeles','ru':'Ссылка обнаружена в буфере','ku':'بەستەرێک لە کلیپبۆرد دۆزرایەوە'});
  String get noDownloadsYet     => _t({'en':'No downloads yet','ar':'لا توجد تنزيلات بعد','zh':'暂无下载','es':'Sin descargas aún','ru':'Загрузок пока нет','ku':'هێشتا داگرتنێک نییە'});
  String get pasteToStart       => _t({'en':'Paste a URL above to get started','ar':'الصق رابطاً أعلاه للبدء','zh':'粘贴链接开始下载','es':'Pega un URL arriba para empezar','ru':'Вставьте URL выше чтобы начать','ku':'بەستەرێک لە سەرەوە بچەسپێنە بۆ دەستپێکردن'});

  // ── Queue extra ──────────────────────────────────────────────────────────
  String get downloading        => _t({'en':'Downloading','ar':'جارٍ التنزيل','zh':'正在下载','es':'Descargando','ru':'Загружается','ku':'داگیردەکرێت'});
  String get queued             => _t({'en':'Queued','ar':'في الانتظار','zh':'排队中','es':'En cola','ru':'В очереди','ku':'ڕیزکراو'});
  String get paused             => _t({'en':'Paused','ar':'متوقف مؤقتاً','zh':'已暂停','es':'Pausado','ru':'На паузе','ku':'ڕاگیراو'});
  String get noActiveDownloads  => _t({'en':'No active downloads','ar':'لا توجد تنزيلات نشطة','zh':'暂无活动下载','es':'Sin descargas activas','ru':'Нет активных загрузок','ku':'هیچ داگرتنێکی چالاک نییە'});
  String get queueIsEmpty       => _t({'en':'Queue is empty','ar':'قائمة الانتظار فارغة','zh':'队列为空','es':'Cola vacía','ru':'Очередь пуста','ku':'ڕیز بەتاڵە'});

  // ── Live recording ───────────────────────────────────────────────────────
  String get quality            => _t({'en':'Quality','ar':'الجودة','zh':'质量','es':'Calidad','ru':'Качество','ku':'کوالیتی'});
  String get maxDuration        => _t({'en':'Max Duration','ar':'المدة القصوى','zh':'最长时长','es':'Duración máxima','ru':'Макс. длительность','ku':'زۆرترین ماوە'});
  String get unlimited          => _t({'en':'Unlimited','ar':'غير محدود','zh':'不限','es':'Sin límite','ru':'Без ограничений','ku':'بێ سنوور'});
  String get record             => _t({'en':'Record','ar':'تسجيل','zh':'录制','es':'Grabar','ru':'Записать','ku':'تۆمارکردن'});
  String get pasteLiveUrl       => _t({'en':'Paste a live stream URL…','ar':'الصق رابط البث المباشر…','zh':'粘贴直播链接…','es':'Pega la URL del stream en vivo…','ru':'Вставьте URL прямой трансляции…','ku':'بەستەری بەڵێوەدانی ڕاستەوخۆ بچەسپێنە…'});
  String get noActiveRecordings => _t({'en':'No active recordings','ar':'لا توجد تسجيلات نشطة','zh':'暂无活动录制','es':'Sin grabaciones activas','ru':'Нет активных записей','ku':'هیچ تۆمارکردنێکی چالاک نییە'});
  String get pasteUrlAndRecord  => _t({'en':'Paste a URL above and press Record','ar':'الصق رابطاً أعلاه ثم اضغط تسجيل','zh':'粘贴链接后点击录制','es':'Pega un URL y presiona Grabar','ru':'Вставьте URL и нажмите Записать','ku':'بەستەرێک بچەسپێنە و تۆمار بکە'});
  String liveRecordLimit(int n) => _t({'en':'Up to $n simultaneous streams','ar':'حتى $n بث متزامن','zh':'最多 $n 个同时录制','es':'Hasta $n streams simultáneos','ru':'До $n потоков одновременно','ku':'هەتا $n بەڵێوەدانی ئەکتیڤ'});
  String maxRecordingsMsg(int n) => _t({'en':'Maximum $n recordings reached','ar':'وصلت للحد الأقصى $n تسجيل','zh':'已达到最大 $n 个录制','es':'Máximo de $n grabaciones alcanzado','ru':'Достигнут лимит $n записей','ku':'زۆرترین $n تۆمارکردن گەیشتوە'});
  String get enterValidUrl      => _t({'en':'Please enter a valid URL','ar':'الرجاء إدخال رابط صحيح','zh':'请输入有效链接','es':'Ingresa una URL válida','ru':'Введите корректный URL','ku':'تکایە بەستەرێکی دروست بنووسە'});
  String get cookieWarning      => _t({'en':'Some platforms may require cookies for private or age-restricted streams.','ar':'بعض المنصات قد تحتاج كوكيز للبث المحمي أو المخصص لأعمار محددة.','zh':'某些平台可能需要Cookies才能录制私有或年龄限制的直播。','es':'Algunas plataformas pueden requerir cookies para streams privados.','ru':'Некоторые платформы могут требовать куки для частных трансляций.','ku':'هەندێک پلاتفۆرم دەبێت کووکیز هەبێت بۆ بەڵێوەدانە تایبەتەکان.'});

  // ── Live recording — panel & cards ──────────────────────────────────────
  String get activeRecordings   => _t({'en':'Active Recordings','ar':'التسجيلات النشطة','zh':'活动录制','es':'Grabaciones activas','ru':'Активные записи','ku':'تۆمارەکانی چالاک'});
  String get stopAll            => _t({'en':'Stop All','ar':'إيقاف الكل','zh':'全部停止','es':'Detener todo','ru':'Остановить всё','ku':'هەمووی بوەستێنە'});
  String get convertingToMp4    => _t({'en':'Converting to MP4...','ar':'جارٍ التحويل إلى MP4...','zh':'正在转换为 MP4...','es':'Convirtiendo a MP4...','ru':'Конвертирование в MP4...','ku':'گۆڕینی بۆ MP4...'});
  String get saving             => _t({'en':'Saving...','ar':'جارٍ الحفظ...','zh':'正在保存...','es':'Guardando...','ru':'Сохранение...','ku':'پاشەکەوتکردن...'});
  String get pausedLabel        => _t({'en':'PAUSED','ar':'متوقف','zh':'已暂停','es':'EN PAUSA','ru':'ПАУЗА','ku':'ڕاگیراو'});
  String get recordingSaved     => _t({'en':'Recording Saved','ar':'تم حفظ التسجيل','zh':'录制已保存','es':'Grabación guardada','ru':'Запись сохранена','ku':'تۆمارکردن پاشەکەوت کرا'});
  String get savedToOutput      => _t({'en':'Saved to output directory','ar':'تم الحفظ في مجلد الإخراج','zh':'已保存到输出目录','es':'Guardado en carpeta de salida','ru':'Сохранено в папку вывода','ku':'پاشەکەوت کرا لە پوختەی دەرکەوتن'});
  String get unknownError       => _t({'en':'Unknown error','ar':'خطأ غير معروف','zh':'未知错误','es':'Error desconocido','ru':'Неизвестная ошибка','ku':'هەڵەی نەناسراو'});
  String get openOutputFolder   => _t({'en':'Open Output Folder','ar':'فتح مجلد الإخراج','zh':'打开输出文件夹','es':'Abrir carpeta de salida','ru':'Открыть папку вывода','ku':'پوختەی دەرکەوتن بکەرەوە'});
  String get stopRecording      => _t({'en':'Stop Recording','ar':'إيقاف التسجيل','zh':'停止录制','es':'Detener grabación','ru':'Остановить запись','ku':'تۆمارکردن بوەستێنە'});
  String get removeRecording    => _t({'en':'Remove','ar':'حذف','zh':'删除','es':'Eliminar','ru':'Удалить','ku':'لابردن'});
  String liveRecordingCount(int n) => _t({'en':'$n recording${n != 1 ? 's' : ''}','ar':'$n تسجيل','zh':'$n 个录制','es':'$n grabacion${n != 1 ? 'es' : ''}','ru':'$n запис${n == 1 ? 'ь' : 'и'}','ku':'$n تۆمار'});
  String get liveStatusIdle       => _t({'en':'Idle','ar':'خامل','zh':'空闲','es':'Inactivo','ru':'Ожидание','ku':'بەتاڵ'});
  String get liveStatusConnecting => _t({'en':'Connecting','ar':'جارٍ الاتصال','zh':'连接中','es':'Conectando','ru':'Подключение','ku':'پەیوەندیکردن'});
  String get liveStatusRecording  => _t({'en':'Recording','ar':'جارٍ التسجيل','zh':'录制中','es':'Grabando','ru':'Запись','ku':'تۆمارکردن'});
  String get liveStatusPaused     => _t({'en':'Paused','ar':'متوقف مؤقتاً','zh':'已暂停','es':'Pausado','ru':'На паузе','ku':'ڕاگیراو'});
  String get liveStatusResuming   => _t({'en':'Resuming','ar':'جارٍ الاستئناف','zh':'恢复中','es':'Reanudando','ru':'Возобновление','ku':'بەردەوامبوونەوە'});
  String get liveStatusStopping   => _t({'en':'Saving...','ar':'جارٍ الحفظ...','zh':'保存中...','es':'Guardando...','ru':'Сохранение...','ku':'پاشەکەوتکردن...'});
  String get liveStatusSaved      => _t({'en':'Saved','ar':'محفوظ','zh':'已保存','es':'Guardado','ru':'Сохранено','ku':'پاشەکەوتکراو'});
  String get liveStatusFailed     => _t({'en':'Failed','ar':'فشل','zh':'失败','es':'Fallido','ru':'Ошибка','ku':'شکستهێنا'});

  // ── Expose language code for widgets that need it ─────────────────────
  String get languageCode => _code;

  // ── Update banner / dialog strings ──────────────────────────────────────
  String get updateAvailable    => _t({'en':'Update available','ar':'تحديث متوفر','zh':'有可用更新','es':'Actualización disponible','ru':'Доступно обновление','ku':'نوێکردنەوە بەردەستە'});
  String get updateReady        => _t({'en':'Update ready — Restart to update','ar':'التحديث جاهز — أعد التشغيل للتحديث','zh':'更新就绪 — 重启以更新','es':'Actualización lista — Reinicia para actualizar','ru':'Обновление готово — перезапустите','ku':'نوێکردنەوە ئامادەیە — دووبارە بەکارببەرە'});
  String get updateDownloading  => _t({'en':'Downloading update','ar':'جارٍ تحميل التحديث','zh':'正在下载更新','es':'Descargando actualización','ru':'Загрузка обновления','ku':'نوێکردنەوە داگیردەکرێت'});
  String get updateVerifying    => _t({'en':'Verifying update','ar':'جارٍ التحقق من التحديث','zh':'正在验证更新','es':'Verificando actualización','ru':'Проверка обновления','ku':'نوێکردنەوە پشکنیندەکرێت'});
  String get updateInstalling   => _t({'en':'Installing update','ar':'جارٍ تثبيت التحديث','zh':'正在安装更新','es':'Instalando actualización','ru':'Установка обновления','ku':'نوێکردنەوە دادەمەزرێت'});
  String get updateFailed       => _t({'en':'Update failed','ar':'فشل التحديث','zh':'更新失败','es':'Error de actualización','ru':'Ошибка обновления','ku':'نوێکردنەوە شکستی هێنا'});
  String get updateChecking     => _t({'en':'Checking for updates…','ar':'جارٍ التحقق من التحديثات…','zh':'正在检查更新…','es':'Buscando actualizaciones…','ru':'Проверка обновлений…','ku':'بەدواداچوون بۆ نوێکردنەوە…'});
  String get restartAndInstall  => _t({'en':'Restart & Install','ar':'إعادة التشغيل والتثبيت','zh':'重启并安装','es':'Reiniciar e instalar','ru':'Перезапустить и установить','ku':'دووبارە بەکارببە و دامەزرێنە'});
  String get retryUpdate        => _t({'en':'Retry','ar':'إعادة المحاولة','zh':'重试','es':'Reintentar','ru':'Повторить','ku':'دووبارەکەشتن'});
  String get openDownloadPage   => _t({'en':'Download Page','ar':'صفحة التحميل','zh':'下载页面','es':'Página de descarga','ru':'Страница загрузки','ku':'پەڕەی داگرتن'});
  String get laterBtn           => _t({'en':'Later','ar':'لاحقاً','zh':'稍后','es':'Más tarde','ru':'Позже','ku':'دواتر'});
  String get updateUpdate       => _t({'en':'Update','ar':'تحديث','zh':'更新','es':'Actualizar','ru':'Обновить','ku':'نوێبکەرەوە'});

  // ── Bandwidth option labels (translated) ────────────────────────────────
  String get bwUnlimited  => _t({'en':'Unlimited','ar':'غير محدود','zh':'不限速','es':'Sin límite','ru':'Без ограничений','ku':'بێ سنوور'});
  String get bw512        => _t({'en':'512 KB/s','ar':'512 ك.ب/ث','zh':'512 KB/秒','es':'512 KB/s','ru':'512 КБ/с','ku':'512 ک.ب/چ'});
  String get bw1mb        => _t({'en':'1 MB/s','ar':'1 م.ب/ث','zh':'1 MB/秒','es':'1 MB/s','ru':'1 МБ/с','ku':'1 م.ب/چ'});
  String get bw2mb        => _t({'en':'2 MB/s','ar':'2 م.ب/ث','zh':'2 MB/秒','es':'2 MB/s','ru':'2 МБ/с','ku':'2 م.ب/چ'});
  String get bw5mb        => _t({'en':'5 MB/s','ar':'5 م.ب/ث','zh':'5 MB/秒','es':'5 MB/s','ru':'5 МБ/с','ku':'5 م.ب/چ'});
  String get bw10mb       => _t({'en':'10 MB/s','ar':'10 م.ب/ث','zh':'10 MB/秒','es':'10 MB/s','ru':'10 МБ/с','ku':'10 م.ب/چ'});

  // ── About Page ───────────────────────────────────────────────────────────

  /// "حمل العالم، بجذور من أور."  — the app tagline, translated per locale
  String get appTagline => _t({
    'en': 'Download the World, Rooted in Ur.',
    'ar': 'حمّل العالم، بجذور من أور.',
    'zh': '下载世界，植根于吾尔。',
    'es': 'Descarga el mundo, con raíces en Ur.',
    'ru': 'Загружай мир, уходя корнями в Ур.',
    'ku': 'جیهان داگرە، ریشەی لە ئوور.',
  });

  String get aboutApp         => _t({'en':'About','ar':'حول البرنامج','zh':'关于','es':'Acerca de','ru':'О программе','ku':'دەربارەی بەرنامە'});
  String get developer        => _t({'en':'Developer','ar':'المطور','zh':'开发者','es':'Desarrollador','ru':'Разработчик','ku':'پێشکەوتنەر'});

  String get developerName    => _t({
    'en': 'Kodna Team',
    'ar': 'فريق كودنا',
    'zh': 'Kodna 团队',
    'es': 'Equipo Kodna',
    'ru': 'Команда Kodna',
    'ku': 'تیمی کۆدنا',
  });

  String get website          => _t({'en':'Website','ar':'الموقع الإلكتروني','zh':'官方网站','es':'Sitio web','ru':'Веб-сайт','ku':'ماڵپەڕ'});
  String get version          => _t({'en':'Version','ar':'الإصدار','zh':'版本','es':'Versión','ru':'Версия','ku':'وەشان'});

  /// ── UPDATED: "Designed & developed with pride in Iraq by Dhia Darem."
  String get madeWith => _t({
    'en': 'Designed & developed by Dhia Darem.',
    'ar': 'صُمم وطُوّر بواسطة ضياء دارم.',
    'zh': '由 Dhia Darem 设计与开发。',
    'es': 'Diseñado y desarrollado por Dhia Darem.',
    'ru': 'Разработано Dhia Darem.',
    'ku': 'دیزاینکراو و پەرەپێدراوە بەلایەن ضياء دارم.',
  });

  String get allRightsReserved => _t({'en':'All rights reserved','ar':'جميع الحقوق محفوظة','zh':'保留所有权利','es':'Todos los derechos reservados','ru':'Все права защищены','ku':'هەموو مافەکان پارێزراون'});

  // ── Binary / engine update ────────────────────────────────────────────────
  String get updateEngine         => _t({'en':'Auto Update','ar':'تحديث تلقائي','zh':'自动更新','es':'Actualización automática','ru':'Авто-обновление','ku':'نوێکردنەوەی خۆکار'});
  String get updateEngineSubtitle => _t({'en':'Auto-check every 12 h','ar':'فحص تلقائي كل 12 ساعة','zh':'每12小时自动检查','es':'Verificación automática cada 12 h','ru':'Проверка каждые 12 ч','ku':'بە خۆکاری هەموو ١٢ کاتژمێر پشکنیندەکرێت'});
  String get updateEngineChecking => _t({'en':'Checking for updates…','ar':'جارٍ التحقق من التحديثات…','zh':'正在检查更新…','es':'Buscando actualizaciones…','ru':'Проверка обновлений…','ku':'بەدواداچوون بۆ نوێکردنەوە…'});
  String updateEngineDownloading(String bin, String pct) => _t({'en':'Downloading $bin  $pct','ar':'جارٍ تحميل $bin  $pct','zh':'正在下载 $bin  $pct','es':'Descargando $bin  $pct','ru':'Загрузка $bin  $pct','ku':'$bin داگیردەکرێت  $pct'});
  String updateEngineExtracting(String bin) => _t({'en':'Installing $bin…','ar':'جارٍ تثبيت $bin…','zh':'正在安装 $bin…','es':'Instalando $bin…','ru':'Установка $bin…','ku':'$bin دادەمەزرێت…'});
  String updateEngineUpdated(String bin, String from, String to) => _t({'en':'$bin updated  $from → $to ✓','ar':'تم تحديث $bin  $from ← $to ✓','zh':'$bin 已更新  $from → $to ✓','es':'$bin actualizado  $from → $to ✓','ru':'$bin обновлён  $from → $to ✓','ku':'$bin نوێکرایەوە  $from → $to ✓'});
  String get updateEngineFailed   => _t({'en':'Engine update failed','ar':'فشل تحديث المحرك','zh':'引擎更新失败','es':'Error al actualizar el motor','ru':'Ошибка обновления движка','ku':'نوێکردنەوەی ئەنجینە شکستی هێنا'});
  String get updateEngineUpToDate => _t({'en':'Engine is up to date','ar':'المحرك محدّث','zh':'引擎已是最新','es':'Motor actualizado','ru':'Движок актуален','ku':'ئەنجینە نوێترین وەشانیدایە'});

  // ── Server Cookies token ──────────────────────────────────────────────────
  String get serverCookiesToken      => _t({'en':'Server Cookies','ar':'كوكيز الخادم','zh':'服务器Cookies','es':'Cookies del servidor','ru':'Серверные куки','ku':'کووکیزی سێرڤەر'});
  String get serverTokenTitle        => _t({'en':'GitHub Access Token','ar':'رمز وصول GitHub','zh':'GitHub 访问令牌','es':'Token de acceso GitHub','ru':'Токен доступа GitHub','ku':'تۆکێنی دەستڕاگەیشتن بە GitHub'});
  String get serverTokenHint         => _t({'en':'ghp_xxxxxxxxxxxxxxxxxxxx','ar':'ghp_xxxxxxxxxxxxxxxxxxxx','zh':'ghp_xxxxxxxxxxxxxxxxxxxx','es':'ghp_xxxxxxxxxxxxxxxxxxxx','ru':'ghp_xxxxxxxxxxxxxxxxxxxx','ku':'ghp_xxxxxxxxxxxxxxxxxxxx'});
  String get serverTokenSave         => _t({'en':'Save & Sync','ar':'حفظ ومزامنة','zh':'保存并同步','es':'Guardar y sincronizar','ru':'Сохранить и синхронизировать','ku':'پاشەکەوت بکە و هاوکاتبکە'});
  String get serverTokenClear        => _t({'en':'Clear Token','ar':'مسح الرمز','zh':'清除令牌','es':'Borrar token','ru':'Удалить токен','ku':'تۆکێن پاک بکەرەوە'});
  String get serverTokenNotSet       => _t({'en':'No token — tap to configure','ar':'لا يوجد رمز — اضغط للإعداد','zh':'未设置令牌 — 点击配置','es':'Sin token — toca para configurar','ru':'Токен не настроен — нажмите для настройки','ku':'تۆکێن نییە — بکە بۆ ڕێکخستن'});
  String get serverTokenSyncing      => _t({'en':'Syncing cookies…','ar':'جارٍ مزامنة الكوكيز…','zh':'正在同步Cookies…','es':'Sincronizando cookies…','ru':'Синхронизация куки…','ku':'کووکیز هاوکاتدەکرێت…'});
  String get serverTokenSyncOk       => _t({'en':'Cookies synced','ar':'تمت المزامنة','zh':'Cookies 已同步','es':'Cookies sincronizadas','ru':'Куки синхронизированы','ku':'کووکیز هاوکات کرا'});
  String get serverTokenSyncFailed   => _t({'en':'Sync failed','ar':'فشلت المزامنة','zh':'同步失败','es':'Error de sincronización','ru':'Ошибка синхронизации','ku':'هاوکاتکردن شکستی هێنا'});

  // ── Remote Config tile (github_config_tile) ─────────────────────────────
  String get remoteConfigTitle       => _t({'en':'Remote Configuration','ar':'الإعدادات البعيدة','zh':'远程配置','es':'Configuración remota','ru':'Удалённая конфигурация','ku':'ڕێکخستنی دوور'});
  String get remoteConfigDialog      => _t({'en':'Remote Config','ar':'الإعدادات البعيدة','zh':'远程配置','es':'Config remota','ru':'Удалённая конфигурация','ku':'ڕێکخستنی دوور'});
  String get remoteConfigToken       => _t({'en':'GitHub Token','ar':'رمز GitHub','zh':'GitHub 令牌','es':'Token GitHub','ru':'Токен GitHub','ku':'تۆکێنی GitHub'});
  String get remoteConfigUrl         => _t({'en':'Config URL (optional)','ar':'رابط الإعداد (اختياري)','zh':'配置URL（可选）','es':'URL de config (opcional)','ru':'URL конфига (необязательно)','ku':'بەستەری ڕێکخستن (ئارەزووی)'});
  String get remoteConfigUrlHint     => _t({'en':'Leave empty to use default URL','ar':'اتركه فارغاً لاستخدام الرابط الافتراضي','zh':'留空使用默认URL','es':'Deja vacío para usar URL por defecto','ru':'Оставьте пустым для URL по умолчанию','ku':'بەتاڵ بهێڵە بۆ بەکارهێنانی بەستەری بنەڕەتی'});
  String get remoteConfigSave        => _t({'en':'Save & Sync','ar':'حفظ ومزامنة','zh':'保存并同步','es':'Guardar y sincronizar','ru':'Сохранить и синхронизировать','ku':'پاشەکەوت بکە و هاوکاتبکە'});
  String get remoteConfigClear       => _t({'en':'Clear','ar':'مسح','zh':'清除','es':'Limpiar','ru':'Очистить','ku':'پاک بکەرەوە'});
  String get remoteConfigCancel      => _t({'en':'Cancel','ar':'إلغاء','zh':'取消','es':'Cancelar','ru':'Отмена','ku':'پاشگەزبوونەوە'});
  String get remoteConfigSetup       => _t({'en':'Configure token','ar':'إعداد الرمز','zh':'配置令牌','es':'Configurar token','ru':'Настроить токен','ku':'تۆکێن ڕێکبخە'});
  String get remoteConfigRefresh     => _t({'en':'Refresh now','ar':'تحديث الآن','zh':'立即刷新','es':'Actualizar ahora','ru':'Обновить сейчас','ku':'ئێستا نوێبکەرەوە'});
  String get remoteConfigSyncing     => _t({'en':'Syncing…','ar':'جارٍ المزامنة…','zh':'同步中…','es':'Sincronizando…','ru':'Синхронизация…','ku':'هاوکاتکردن…'});
  String get remoteConfigSynced      => _t({'en':'Synced','ar':'تمت المزامنة','zh':'已同步','es':'Sincronizado','ru':'Синхронизировано','ku':'هاوکات کرا'});
  String get remoteConfigCached      => _t({'en':'Cached','ar':'مخزّن','zh':'已缓存','es':'En caché','ru':'Кэшировано','ku':'کێش کرا'});
  String get remoteConfigSyncFailed  => _t({'en':'Sync failed','ar':'فشلت المزامنة','zh':'同步失败','es':'Error de sincronización','ru':'Ошибка синхронизации','ku':'هاوکاتکردن شکستی هێنا'});
  String get remoteConfigNeverSynced => _t({'en':'Never synced','ar':'لم تتم المزامنة بعد','zh':'从未同步','es':'Nunca sincronizado','ru':'Никогда не синхронизировалось','ku':'هەرگیز هاوکات نەکرا'});

  // ── Engine update ─────────────────────────────────────────────────────────
  String get engineUpdateNow         => _t({'en':'Update now','ar':'تحديث الآن','zh':'立即更新','es':'Actualizar ahora','ru':'Обновить сейчас','ku':'ئێستا نوێبکەرەوە'});

  // ── Internal helper ──────────────────────────────────────────────────────
  String _t(Map<String, String> map) =>
      map[_code] ?? map['en'] ?? map.values.first;
}

// ─── Riverpod provider ────────────────────────────────────────────────────
final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings(locale.languageCode);
});
