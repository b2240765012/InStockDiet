/// Gerçek API hazır olana kadar kullanılan sahte (mock) veri servisi.
/// Elindeki malzemelere ve hedefe göre basit bir mantıkla iki tarif üretir:
/// 1) Tam eşleşme (sadece dolaptaki malzemelerle)
/// 2) 1-2 eksikle yap (marketten alınacak malzemelerle)
class MockService {
  static Map<String, dynamic> generateSuggestions({
    required List<String> pantry,
    required String goal,
  }) {
    final baseIngredient = pantry.isNotEmpty ? pantry.first : 'Sebze';
    final ownedSample = pantry.isNotEmpty ? pantry.take(3).join(', ') : 'elinizdeki malzemeler';

    final tamEslesme = {
      'isim': 'Zeytinyağlı $baseIngredient Sote',
      'tur': 'tam',
      'kalori': 320,
      'protein': 18,
      'karbonhidrat': 28,
      'yag': 14,
      'sure': '20 dk',
      'malzemeler': pantry.isNotEmpty ? List<String>.from(pantry) : ['Yumurta', 'Soğan', 'Domates'],
      'adimlar': [
        'Tüm malzemeleri küp küp doğrayın.',
        'Tavaya zeytinyağını alıp orta ateşte ısıtın.',
        '$ownedSample malzemelerini sırasıyla ekleyip 8-10 dakika soteleyin.',
        'Tuz, karabiber ve isteğe göre baharat ekleyip 2 dakika daha pişirin.',
        'Sıcak olarak servis edin.',
      ],
      'hedefUyumu': _goalNote(goal),
    };

    final missing = _missingFor(pantry);

    final eksikMalzemeli = {
      'isim': 'Fırında $baseIngredient ve Tavuk',
      'tur': 'eksik',
      'kalori': 410,
      'protein': 35,
      'karbonhidrat': 22,
      'yag': 16,
      'sure': '35 dk',
      'eksikMalzemeler': missing,
      'malzemeler': [...pantry, ...missing],
      'adimlar': [
        'Fırını 200°C\'ye ısıtın.',
        'Tavuk göğsünü ve elinizdeki malzemeleri fırın tepsisine yerleştirin.',
        'Zeytinyağı, tuz ve baharatlarla harmanlayın.',
        '${missing.join(', ')} malzemelerini de ekleyip karıştırın.',
        '25-30 dakika fırınlayıp sıcak servis edin.',
      ],
      'hedefUyumu': _goalNote(goal),
    };

    return {
      'tamEslesme': tamEslesme,
      'eksikMalzemeli': eksikMalzemeli,
    };
  }

  static List<String> _missingFor(List<String> pantry) {
    const candidates = ['Tavuk Göğsü', 'Zeytinyağı', 'Sarımsak', 'Limon'];
    return candidates
        .where((c) => !pantry.any((p) => p.toLowerCase() == c.toLowerCase()))
        .take(2)
        .toList();
  }

  static String _goalNote(String goal) {
    switch (goal) {
      case 'Kilo Vermek':
        return 'Düşük kalorili, yüksek lifli bir seçenek.';
      case 'Kilo Almak':
        return 'Kalori ve protein değeri artırılmış bir seçenek.';
      default:
        return 'Dengeli makro dağılımıyla formunuzu korumanıza yardımcı olur.';
    }
  }
}
