import 'package:flutter/material.dart';
import '../data/mock_service.dart';

/// Uygulamanın tek merkezi state'i.
/// En basit ve kararlı yöntem olarak ChangeNotifier + Provider kullanılıyor.
class AppState extends ChangeNotifier {
  // ---- Hedef ----
  String goal = 'Kilo Vermek';

  // ---- Sanal Dolap ----
  final List<String> pantry = [];

  // ---- Sonuç ekranı state'i ----
  bool isLoading = false;
  Map<String, dynamic>? matchedRecipe; // Tam eşleşme
  Map<String, dynamic>? partialRecipe; // 1-2 eksikle yap

  // ---- Hafıza notu (son eklenen yemek sonrası mesaj) ----
  String? lastMemoryNote;

  // ---- Tema ----
  ThemeMode themeMode = ThemeMode.system;

  static const List<String> weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  // Gün -> o gün eklenen yemekler listesi
  final Map<String, List<Map<String, dynamic>>> weeklyLog = {
    for (final d in weekDays) d: <Map<String, dynamic>>[],
  };

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setGoal(String g) {
    goal = g;
    notifyListeners();
  }

  void addIngredient(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    final exists = pantry.any((e) => e.toLowerCase() == value.toLowerCase());
    if (!exists) {
      pantry.add(value);
      notifyListeners();
    }
  }

  void removeIngredient(String item) {
    pantry.remove(item);
    notifyListeners();
  }

  /// Mock API isteğini simüle eder (küçük bir gecikme ile).
  Future<void> findMeals() async {
    isLoading = true;
    matchedRecipe = null;
    partialRecipe = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1100));

    final result = MockService.generateSuggestions(pantry: pantry, goal: goal);
    matchedRecipe = result['tamEslesme'];
    partialRecipe = result['eksikMalzemeli'];

    isLoading = false;
    notifyListeners();
  }

  /// Seçilen tarifi haftalık takvime ekler ve dolaptaki
  /// kullanılan malzemeleri azaltır.
  void addMealToLog(
    String day,
    Map<String, dynamic> recipe, {
    required List<String> consumedFromPantry,
  }) {
    weeklyLog[day]!.add({
      'isim': recipe['isim'],
      'kalori': recipe['kalori'],
    });

    final removedItems = <String>[];
    for (final item in consumedFromPantry) {
      final idx = pantry.indexWhere((p) => p.toLowerCase() == item.toLowerCase());
      if (idx != -1) {
        removedItems.add(pantry[idx]);
        pantry.removeAt(idx);
      }
    }

    lastMemoryNote = removedItems.isEmpty
        ? '"${recipe['isim']}" listenize eklendi.'
        : '"${recipe['isim']}" listenize eklendi. Dolabınızdaki ${removedItems.join(', ')} azaltıldı.';

    notifyListeners();
  }
}
