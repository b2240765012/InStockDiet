import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ResultsScreen extends StatefulWidget {
  final VoidCallback onAddedToLog;
  const ResultsScreen({super.key, required this.onAddedToLog});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _todayName() {
    final weekday = DateTime.now().weekday; // 1 = Pazartesi
    return AppState.weekDays[weekday - 1];
  }

  Future<void> _confirmAdd(
    AppState appState,
    Map<String, dynamic> recipe, {
    required List<String> consumed,
  }) async {
    final today = _todayName();
    final chosenDay = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Hangi güne eklensin?'),
        children: AppState.weekDays.map((d) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, d),
            child: Row(
              children: [
                Text(d),
                if (d == today) ...[
                  const SizedBox(width: 8),
                  const Text('(bugün)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (chosenDay == null) return;

    appState.addMealToLog(chosenDay, recipe, consumedFromPantry: consumed);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hafıza Notu: ${appState.lastMemoryNote ?? ""}')),
    );
    widget.onAddedToLog();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.matchedRecipe == null || appState.partialRecipe == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Henüz öneri yok.\n"Dolap" sekmesinden malzeme ekleyip arama yapın.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      );
    }

    final matched = appState.matchedRecipe!;
    final partial = appState.partialRecipe!;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tam Eşleşme'),
            Tab(text: '1-2 Eksikle Yap'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _RecipeView(
                recipe: matched,
                onAdd: () => _confirmAdd(
                  appState,
                  matched,
                  consumed: List<String>.from(matched['malzemeler']),
                ),
              ),
              _RecipeView(
                recipe: partial,
                showMissing: true,
                onAdd: () => _confirmAdd(
                  appState,
                  partial,
                  consumed: List<String>.from(partial['malzemeler'])
                      .where((m) => appState.pantry.contains(m))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeView extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onAdd;
  final bool showMissing;

  const _RecipeView({
    required this.recipe,
    required this.onAdd,
    this.showMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(recipe['isim'], style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                recipe['hedefUyumu'] ?? '',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(icon: Icons.local_fire_department, label: '${recipe['kalori']} kcal'),
                  _StatChip(icon: Icons.egg_alt_outlined, label: 'P: ${recipe['protein']}g'),
                  _StatChip(icon: Icons.rice_bowl_outlined, label: 'K: ${recipe['karbonhidrat']}g'),
                  _StatChip(icon: Icons.opacity, label: 'Y: ${recipe['yag']}g'),
                  _StatChip(icon: Icons.timer_outlined, label: '${recipe['sure']}'),
                ],
              ),
              const SizedBox(height: 20),
              if (showMissing) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shopping_cart_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Marketten alman gerekenler: ${(recipe['eksikMalzemeler'] as List).join(', ')}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text('Malzemeler', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List<String>.from(recipe['malzemeler']).map(
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                      Text(m),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Yapılışı', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List<String>.from(recipe['adimlar']).asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.value)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Bu Yemeği Yedim, Listeme Ekle'),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
