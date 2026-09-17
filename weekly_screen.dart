import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  String _todayName() {
    final weekday = DateTime.now().weekday; // 1 = Pazartesi ... 7 = Pazar
    return AppState.weekDays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final today = _todayName();

    return Column(
      children: [
        if (appState.lastMemoryNote != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Hafıza Notu: ${appState.lastMemoryNote}'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: AppState.weekDays.length,
            itemBuilder: (context, i) {
              final day = AppState.weekDays[i];
              final meals = appState.weeklyLog[day]!;
              final isToday = day == today;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: isToday
                      ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(day, style: Theme.of(context).textTheme.titleMedium),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Bugün',
                                style: TextStyle(fontSize: 11, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (meals.isEmpty)
                        Text(
                          'Henüz yemek eklenmedi.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        )
                      else
                        ...meals.map(
                          (m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.restaurant, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${m['isim']}')),
                                Text(
                                  '${m['kalori']} kcal',
                                  style: TextStyle(color: Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
