import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/tile_item.dart';
import '../models/phrase.dart';
import '../services/storage_service.dart';

class AppController extends ChangeNotifier {
  AppController({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;
  final FlutterTts _tts = FlutterTts();
  final Uuid _uuid = const Uuid();

  // Keys
  static const _kCategories = 'categories';
  static const _kTiles = 'tiles';
  static const _kPhrases = 'phrases';
  static const _kSelectedCategoryId = 'selectedCategoryId';
  static const _kTtsRate = 'ttsRate';
  static const _kTtsPitch = 'ttsPitch';

  // State
  final List<Category> categories = [];
  final List<TileItem> tiles = [];
  final List<Phrase> phrases = [];
  String? selectedCategoryId;

  final List<String> messageTokens = [];

  double ttsRate = 0.45;
  double ttsPitch = 1.0;

  Future<void> load() async {
    // TTS defaults
    ttsRate = _storage.get<num>(_kTtsRate)?.toDouble() ?? 0.45;
    ttsPitch = _storage.get<num>(_kTtsPitch)?.toDouble() ?? 1.0;

    await _tts.setSpeechRate(ttsRate);
    await _tts.setPitch(ttsPitch);

    final catsRaw = _storage.get(_kCategories);
    final tilesRaw = _storage.get(_kTiles);
    final phrasesRaw = _storage.get(_kPhrases);

    if (catsRaw is List) {
      categories
        ..clear()
        ..addAll(
          catsRaw.whereType<Map>().map(
            (m) => Category.fromJson(Map<String, dynamic>.from(m)),
          ),
        );
    }

    if (tilesRaw is List) {
      tiles
        ..clear()
        ..addAll(
          tilesRaw.whereType<Map>().map(
            (m) => TileItem.fromJson(Map<String, dynamic>.from(m)),
          ),
        );
    }

    if (phrasesRaw is List) {
      phrases
        ..clear()
        ..addAll(
          phrasesRaw.whereType<Map>().map(
            (m) => Phrase.fromJson(Map<String, dynamic>.from(m)),
          ),
        );
    }

    selectedCategoryId = _storage.get<String>(_kSelectedCategoryId);

    if (categories.isEmpty) {
      _seedDefaults();
      await _persistAll();
    } else {
      selectedCategoryId ??= categories.first.id;
    }

    notifyListeners();
  }

  void _seedDefaults() {
    categories
      ..clear()
      ..addAll([
        Category(id: _uuid.v4(), name: 'Core', sortOrder: 0),
        Category(id: _uuid.v4(), name: 'Needs', sortOrder: 1),
        Category(id: _uuid.v4(), name: 'Feelings', sortOrder: 2),
        Category(id: _uuid.v4(), name: 'People', sortOrder: 3),
      ]);

    selectedCategoryId = categories.first.id;

    tiles
      ..clear()
      ..addAll([
        _tile(categories[0].id, 'I', 'I', 0),
        _tile(categories[0].id, 'want', 'want', 1),
        _tile(categories[0].id, 'need', 'need', 2),
        _tile(categories[0].id, 'go', 'go', 3),
        _tile(categories[0].id, 'help', 'help', 4, fav: true),
        _tile(categories[0].id, 'yes', 'yes', 5, fav: true),
        _tile(categories[0].id, 'no', 'no', 6, fav: true),
        _tile(categories[1].id, 'toilet', 'I need the toilet', 0, fav: true),
        _tile(categories[1].id, 'water', 'I want water', 1),
        _tile(categories[1].id, 'break', 'I need a break', 2, fav: true),
        _tile(categories[2].id, 'happy', 'I feel happy', 0),
        _tile(categories[2].id, 'sad', 'I feel sad', 1),
        _tile(categories[2].id, 'angry', 'I feel angry', 2),
        _tile(categories[2].id, 'anxious', 'I feel anxious', 3),
        _tile(categories[3].id, 'Mum', 'Mum', 0),
        _tile(categories[3].id, 'Dad', 'Dad', 1),
        _tile(categories[3].id, 'Teacher', 'Teacher', 2),
        _tile(categories[3].id, 'Friend', 'My friend', 3),
      ]);

    phrases
      ..clear()
      ..addAll([
        Phrase(id: _uuid.v4(), text: 'Hi', pinned: true, sortOrder: 0),
        Phrase(
          id: _uuid.v4(),
          text: 'Please give me a minute.',
          pinned: true,
          sortOrder: 1,
        ),
        Phrase(
          id: _uuid.v4(),
          text: 'I need a break.',
          pinned: true,
          sortOrder: 2,
        ),
        Phrase(id: _uuid.v4(), text: 'Thank you.', pinned: true, sortOrder: 3),
      ]);
  }

  TileItem _tile(
    String catId,
    String label,
    String speakText,
    int order, {
    bool fav = false,
  }) {
    return TileItem(
      id: _uuid.v4(),
      categoryId: catId,
      label: label,
      speakText: speakText,
      isFavourite: fav,
      sortOrder: order,
    );
  }

  List<Category> get sortedCategories {
    final copy = [...categories];
    copy.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  List<TileItem> tilesForCategory(String? categoryId) {
    final list = tiles.where((t) => t.categoryId == categoryId).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<TileItem> get favourites {
    final list = tiles.where((t) => t.isFavourite).toList();
    list.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return list;
  }

  List<Phrase> get pinnedPhrases {
    final list = phrases.where((p) => p.pinned).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> selectCategory(String id) async {
    selectedCategoryId = id;
    await _storage.putJson(_kSelectedCategoryId, id);
    notifyListeners();
  }

  void addToken(String token) {
    if (token.trim().isEmpty) return;
    messageTokens.add(token);
    notifyListeners();
  }

  void backspaceToken() {
    if (messageTokens.isNotEmpty) {
      messageTokens.removeLast();
      notifyListeners();
    }
  }

  void clearMessage() {
    messageTokens.clear();
    notifyListeners();
  }

  String get composedMessage =>
      messageTokens.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> speakMessage({String? override}) async {
    final text = (override ?? composedMessage).trim();
    if (text.isEmpty) return;

    await _tts.setSpeechRate(ttsRate);
    await _tts.setPitch(ttsPitch);

    // On iOS/Android this uses native TTS. On desktop/web it depends on platform support.
    await _tts.speak(text);
  }

  Future<void> setTts(double rate, double pitch) async {
    ttsRate = rate;
    ttsPitch = pitch;
    await _storage.putJson(_kTtsRate, rate);
    await _storage.putJson(_kTtsPitch, pitch);
    notifyListeners();
  }

  Future<void> toggleFavourite(String tileId) async {
    final t = tiles.firstWhere((x) => x.id == tileId);
    t.isFavourite = !t.isFavourite;
    await _persistTiles();
    notifyListeners();
  }

  // Editing
  Future<void> addCategory(String name) async {
    final order = categories.isEmpty
        ? 0
        : (categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) +
              1);
    categories.add(
      Category(id: _uuid.v4(), name: name.trim(), sortOrder: order),
    );
    await _persistCategories();
    notifyListeners();
  }

  Future<void> renameCategory(String id, String name) async {
    final c = categories.firstWhere((x) => x.id == id);
    c.name = name.trim();
    await _persistCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    categories.removeWhere((c) => c.id == id);
    tiles.removeWhere((t) => t.categoryId == id);
    if (selectedCategoryId == id) {
      selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
      await _storage.putJson(_kSelectedCategoryId, selectedCategoryId ?? '');
    }
    await _persistAll();
    notifyListeners();
  }

  Future<void> addTile({
    required String categoryId,
    required String label,
    required String speakText,
  }) async {
    final existing = tiles.where((t) => t.categoryId == categoryId).toList();
    final order = existing.isEmpty
        ? 0
        : (existing.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) +
              1);

    tiles.add(
      TileItem(
        id: _uuid.v4(),
        categoryId: categoryId,
        label: label.trim(),
        speakText: speakText.trim(),
        isFavourite: false,
        sortOrder: order,
      ),
    );

    await _persistTiles();
    notifyListeners();
  }

  Future<void> updateTile({
    required String tileId,
    required String label,
    required String speakText,
  }) async {
    final t = tiles.firstWhere((x) => x.id == tileId);
    t.label = label.trim();
    t.speakText = speakText.trim();
    await _persistTiles();
    notifyListeners();
  }

  Future<void> deleteTile(String tileId) async {
    tiles.removeWhere((t) => t.id == tileId);
    await _persistTiles();
    notifyListeners();
  }

  Future<void> addPhrase(String text, {bool pinned = false}) async {
    final order = phrases.isEmpty
        ? 0
        : (phrases.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1);
    phrases.add(
      Phrase(
        id: _uuid.v4(),
        text: text.trim(),
        pinned: pinned,
        sortOrder: order,
      ),
    );
    await _persistPhrases();
    notifyListeners();
  }

  Future<void> togglePinnedPhrase(String phraseId) async {
    final p = phrases.firstWhere((x) => x.id == phraseId);
    p.pinned = !p.pinned;
    await _persistPhrases();
    notifyListeners();
  }

  Future<void> deletePhrase(String phraseId) async {
    phrases.removeWhere((p) => p.id == phraseId);
    await _persistPhrases();
    notifyListeners();
  }

  // Backup
  Future<String?> exportBackup() async {
    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'tiles': tiles.map((t) => t.toJson()).toList(),
      'phrases': phrases.map((p) => p.toJson()).toList(),
      'settings': {
        'ttsRate': ttsRate,
        'ttsPitch': ttsPitch,
        'selectedCategoryId': selectedCategoryId,
      },
    };

    final file = await _storage.exportBackupJson(payload: payload);
    return file.path;
  }

  Future<bool> importBackup() async {
    final decoded = await _storage.importBackupJson();
    if (decoded == null) return false;

    try {
      final catList = (decoded['categories'] as List).cast<Map>();
      final tileList = (decoded['tiles'] as List).cast<Map>();
      final phraseList = (decoded['phrases'] as List).cast<Map>();
      final settings = decoded['settings'] as Map<String, dynamic>?;

      categories
        ..clear()
        ..addAll(
          catList.map((m) => Category.fromJson(Map<String, dynamic>.from(m))),
        );
      tiles
        ..clear()
        ..addAll(
          tileList.map((m) => TileItem.fromJson(Map<String, dynamic>.from(m))),
        );
      phrases
        ..clear()
        ..addAll(
          phraseList.map((m) => Phrase.fromJson(Map<String, dynamic>.from(m))),
        );

      if (settings != null) {
        ttsRate = (settings['ttsRate'] as num?)?.toDouble() ?? ttsRate;
        ttsPitch = (settings['ttsPitch'] as num?)?.toDouble() ?? ttsPitch;
        selectedCategoryId =
            settings['selectedCategoryId'] as String? ?? selectedCategoryId;
      }

      if (categories.isNotEmpty) {
        selectedCategoryId ??= categories.first.id;
      }

      await _persistAll();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persistCategories() async {
    await _storage.putJson(
      _kCategories,
      categories.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> _persistTiles() async {
    await _storage.putJson(_kTiles, tiles.map((t) => t.toJson()).toList());
  }

  Future<void> _persistPhrases() async {
    await _storage.putJson(_kPhrases, phrases.map((p) => p.toJson()).toList());
  }

  Future<void> _persistAll() async {
    await Future.wait([
      _persistCategories(),
      _persistTiles(),
      _persistPhrases(),
    ]);
    await _storage.putJson(_kSelectedCategoryId, selectedCategoryId ?? '');
    await _storage.putJson(_kTtsRate, ttsRate);
    await _storage.putJson(_kTtsPitch, ttsPitch);
  }

  // Simple shareable string for "conversation mode"
  String exportMessageAsPlainText() => composedMessage;

  // For debug use only
  @override
  String toString() => jsonEncode({
    'categories': categories.length,
    'tiles': tiles.length,
    'phrases': phrases.length,
  });
}
