import 'package:flutter/foundation.dart';

/// Простой базовый класс "кеш + автообновление".
///
/// Идея по-человечески:
/// - сначала показываем кеш (если есть)
/// - потом обновляем из сети (если нужно)
/// - если интернет упал — ничего не ломаем, просто сохраняем ошибку
abstract class CachedRepository<T> extends ChangeNotifier {
  CachedRepository({
    required T initialData,
    required Duration ttl,
  })  : _data = initialData,
        _ttl = ttl;

  final Duration _ttl;

  T _data;
  DateTime? _updatedAt;
  bool _loading = false;
  Object? _lastError;

  /// Данные (то, что рисует UI)
  T get data => _data;

  /// Когда последний раз обновлялись (из сети или из кеша)
  DateTime? get updatedAt => _updatedAt;

  /// Идёт ли сейчас обновление
  bool get loading => _loading;

  /// Последняя ошибка обновления (если была)
  Object? get lastError => _lastError;

  /// TTL — сколько живут данные, прежде чем их стоит обновить
  Duration get ttl => _ttl;

  /// Читаем кеш (может вернуть null, если кеша нет/битый)
  Future<T?> readCache();

  /// Сохраняем кеш
  Future<void> writeCache(T data, DateTime updatedAt);

  /// Загружаем данные из сети
  Future<T> fetchRemote();

  /// Первый запуск: грузим кеш (быстро) и уведомляем UI.
  Future<void> init() async {
    await _loadCacheOnly();
    // обновление мы не форсим тут, чтобы UI не "подвисал";
    // дальше вызывай refresh() когда надо (например, при заходе во вкладку)
  }

  /// Удобная старая привычка: кеш + сразу обновить
  Future<void> initAndRefresh({bool force = true}) async {
    await init();
    await refresh(force: force);
  }

  bool _isStale() {
    final t = _updatedAt;
    if (t == null) return true;
    return DateTime.now().difference(t) >= _ttl;
  }

  Future<void> _loadCacheOnly() async {
    try {
      final cached = await readCache();
      if (cached == null) return;

      _data = cached;
      // updatedAt обычно внутри readCache восстанавливается отдельно,
      // поэтому не трогаем тут _updatedAt, если readCache её не выставил
      notifyListeners();
    } catch (_) {
      // битый кеш — молча игнорируем
    }
  }

  /// Основная функция: обновить данные.
  ///
  /// - force=false: обновляет только если данные устарели (TTL)
  /// - force=true: обновляет всегда
  Future<void> refresh({bool force = false}) async {
    if (_loading) return;

    if (!force && !_isStale()) {
      return; // свежо — не трогаем сеть
    }

    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final fresh = await fetchRemote();
      _data = fresh;
      _updatedAt = DateTime.now();

      await writeCache(_data, _updatedAt!);
    } catch (e) {
      _lastError = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Если внутри readCache ты восстановил updatedAt — вызови это.
  @protected
  void setUpdatedAtFromCache(DateTime? time) {
    _updatedAt = time;
  }
}
