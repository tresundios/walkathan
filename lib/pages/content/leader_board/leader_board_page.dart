import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../repositories/auth_repository_provider.dart';
import '../../../utils/error_dialog.dart';
import '../../../models/custom_error.dart';
import '../home/home_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/firebase_constants.dart';
import './leader_board_provider.dart';

class LeaderBoardPage extends ConsumerStatefulWidget {

  const LeaderBoardPage({super.key});

  @override
  _LeaderBoardPageState createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends ConsumerState<LeaderBoardPage> {
  



  @override
  Widget build(BuildContext context) {
    final uid = fbAuth.currentUser!.uid;
    final profileState = ref.watch(profileProvider(uid));
    //final maleLeaderboardState = ref.watch(leaderboardDataProvider, 'male');
    // final maleLeaderBoardState = ref.watch(leaderboardDataProvider({'gender': 'male', 'limit': 3}));
    // final femaleLeaderBoardState = ref.watch(leaderboardDataProvider({'gender': 'female', 'limit': 3}));
    // final userSteps = ref.watch(userDataProvider({'user': uid, 'limit': 3}));

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
                  'Welcome ${appUser.name}',
                  style: const TextStyle(fontSize: 24.0),
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
                  
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/maleLeaderBoard');
                  },
                  child: const Text(
                    'Top Mens',
                    style: TextStyle(fontSize: 20),
                  ),
                  
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/femaleLeaderBoard');
                  },
                  child: const Text(
                    'Top Womens',
                    style: TextStyle(fontSize: 20),
                  ),
                  
                ),
              ]
            )
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
