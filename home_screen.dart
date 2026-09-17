import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onFindMeals;
  const HomeScreen({super.key, required this.onFindMeals});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  static const goals = ['Kilo Vermek', 'Kilo Almak', 'Formu Korumak'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient(AppState appState) {
    appState.addIngredient(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hedefin ne?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: goals.map((g) {
                final selected = appState.goal == g;
                return ChoiceChip(
                  label: Text(g),
                  selected: selected,
                  onSelected: (_) => appState.setGoal(g),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text('Sanal Dolabın', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Malzeme ekle (örn. Yumurta)',
                    ),
                    onSubmitted: (_) => _addIngredient(appState),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addIngredient(appState),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: appState.pantry.isEmpty
                  ? Center(
                      child: Text(
                        'Dolabınız boş.\nMalzeme ekleyerek başlayın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: appState.pantry.map((item) {
                          return Chip(
                            label: Text(item),
                            onDeleted: () => appState.removeIngredient(item),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: appState.pantry.isEmpty
                    ? null
                    : () async {
                        widget.onFindMeals();
                        await appState.findMeals();
                      },
                icon: const Icon(Icons.search),
                label: const Text('Bana Uygun Yemek Bul'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
