# Dinamik Diyet ve Yemek Planlama — MVP

Malzemeye göre dinamik diyet ve yemek önerisi sunan Flutter MVP uygulaması.
State yönetimi: **Provider (ChangeNotifier)**. API henüz hazır olmadığı için
`lib/data/mock_service.dart` içinde sahte (mock) bir veri servisi kullanılır.

## Klasör Yapısı

```
dinamik_diyet_app/
├── pubspec.yaml
├── analysis_options.yaml
└── lib/
    ├── main.dart                  # Uygulama giriş noktası
    ├── state/
    │   └── app_state.dart         # Merkezi state (hedef, dolap, sonuçlar, haftalık log)
    ├── data/
    │   └── mock_service.dart      # Sahte API / mock JSON üretici
    ├── theme/
    │   └── app_theme.dart         # Açık/Koyu tema (soft yeşil + gri)
    └── screens/
        ├── root_screen.dart       # Bottom navigation + ekranlar arası geçiş
        ├── home_screen.dart       # Ekran 1: Hedef ve Dolap
        ├── results_screen.dart    # Ekran 2: Günün Önerileri (2 sekme)
        └── weekly_screen.dart     # Ekran 3: Haftalık Takip (Hafıza Notu)
```

## Kurulum Adımları

1. **Flutter SDK'nın kurulu olduğundan emin olun** (3.3.0 veya üzeri):
   ```bash
   flutter --version
   ```

2. **Proje klasörüne girin:**
   ```bash
   cd dinamik_diyet_app
   ```

3. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

4. **Uygulamayı çalıştırın** (bağlı bir emülatör/cihaz veya Chrome ile):
   ```bash
   flutter run
   ```
   Web'de denemek isterseniz:
   ```bash
   flutter run -d chrome
   ```

## Uygulama Akışı

1. **Hedef ve Dolap** ekranında hedefinizi seçin (Kilo Vermek / Kilo Almak /
   Formu Korumak), elinizdeki malzemeleri tek tek ekleyin (Enter veya + butonu),
   dilediğiniz malzemeyi Chip üzerindeki çarpıya basarak silin.
2. **"Bana Uygun Yemek Bul"** butonuna basınca otomatik olarak **Öneriler**
   sekmesine geçilir ve ~1 saniyelik mock bir "API isteği" simüle edilir.
3. **Günün Önerileri** ekranında iki sekme vardır:
   - *Tam Eşleşme*: Sadece dolabınızdaki malzemelerle yapılabilecek tarif.
   - *1-2 Eksikle Yap*: Marketten alınması gereken 1-2 malzeme ile alternatif tarif.
   Alttaki **"Bu Yemeği Yedim, Listeme Ekle"** butonuna basınca hangi güne
   ekleneceğini seçersiniz; kullanılan malzemeler dolaptan düşülür ve bir
   **Hafıza Notu** gösterilir.
4. **Haftalık Takip** ekranında Pazartesi'den Pazar'a kadar tüm günler ve o
   günlere eklenen yemekler listelenir; bugünün kartı vurgulanır.

Sağ üstteki güneş/ay ikonuyla açık/koyu tema arasında manuel geçiş
yapabilirsiniz (varsayılan: sistem teması).

## Notlar / Sonraki Adımlar

- `mock_service.dart` dosyasındaki `generateSuggestions` fonksiyonu, gerçek
  API entegrasyonu geldiğinde bir `ApiService.fetchSuggestions(...)` çağrısıyla
  birebir değiştirilebilecek şekilde tasarlandı (aynı Map<String, dynamic>
  yapısını döndürüyor).
- Flutter sürümünüz 3.27+ ise ve `cardTheme` ile ilgili bir tip hatası
  alırsanız, `app_theme.dart` içindeki `CardTheme(...)` çağrılarını
  `CardThemeData(...)` olarak değiştirmeniz yeterlidir.
