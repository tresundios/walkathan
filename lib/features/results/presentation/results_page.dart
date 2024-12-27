import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/results_repository_provider.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsyncValue = ref.watch(winnersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Winners'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: resultsAsyncValue.when(
          data: (winners) {
            if (winners.isEmpty) {
              return const Center(
                child: Text('No winners yet.'),
              );
            }

            final maleWinners = winners.where((w) => w.gender == 'male').toList();
            final femaleWinners = winners.where((w) => w.gender == 'female').toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top 3 Male Winners',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: maleWinners.length,
                  itemBuilder: (context, index) {
                    final winner = maleWinners[index];
                    return ListTile(
                      title: Text(winner.name),
                      subtitle: Text('Steps: ${winner.steps}'),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Top 3 Female Winners',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: femaleWinners.length,
                  itemBuilder: (context, index) {
                    final winner = femaleWinners[index];
                    return ListTile(
                      title: Text(winner.name),
                      subtitle: Text('Steps: ${winner.steps}'),
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
