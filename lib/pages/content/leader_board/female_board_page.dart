import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../repositories/auth_repository_provider.dart';
import '../../../utils/error_dialog.dart';
import '../../../models/custom_error.dart';
import '../home/home_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/firebase_constants.dart';
import './leader_board_provider.dart';

class FeMaleBoardPage extends ConsumerStatefulWidget {

  const FeMaleBoardPage({super.key});

  @override
  _FeMaleBoardPageState createState() => _FeMaleBoardPageState();
}

class _FeMaleBoardPageState extends ConsumerState<FeMaleBoardPage> {
  



  @override
  Widget build(BuildContext context) {
    final numberOfDays = 3;
    final uid = fbAuth.currentUser!.uid;
    final profileState = ref.watch(profileProvider(uid));
    //final maleLeaderboardState = ref.watch(leaderboardDataProvider, 'male');
    final leaderBoardState = ref.watch(leaderboardDataProvider({'gender': 'female', 'limit': numberOfDays}));
    //final femaleLeaderBoardState = ref.watch(leaderboardDataProvider({'gender': 'female', 'limit': numberOfDays}));
    //final userStepState = ref.watch(userDataProvider({'user': uid, 'limit': numberOfDays}));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leader Board'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).signout();
              } on CustomError catch (e) {
                if (!context.mounted) return;
                errorDialog(context, e);
              }
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              ref.invalidate(profileProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: profileState.when(
        skipLoadingOnRefresh: false,
        data: (appUser) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Top Women Contestants',
                  style: const TextStyle(fontSize: 24.0),
                ),
                const SizedBox(height: 40),
                    Expanded(
                      child: leaderBoardState.when(
                        data: (leaderboardData) {
                          return ListView.builder(
                            itemCount: leaderboardData.length,
                            itemBuilder: (context, index) {
                              final entry = leaderboardData[index];
                              return ListTile(
                                title: Text(entry['name'] ?? 'Anonymous'),
                                trailing: Text(entry['totalSteps'].toString()),
                              );
                            },
                          );
                        },
                        error: (e, _) => Center(child: Text('Error loading leaderboard: $e')),
                        loading: () => const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/walkHome/$uid');
                  },
                  child: const Text(
                    'Walkathan Home',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          );
        },
        error: (e, _) {
          final error = e as CustomError;

          return Center(
            child: Text(
              'code: ${error.code}\nplugin: ${error.plugin}\nmessage: ${error.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      
 
    );
  }
}
