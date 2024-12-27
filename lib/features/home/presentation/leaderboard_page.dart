import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('1. John Doe'),
            trailing: Text('20,000 Steps'),
          ),
          ListTile(
            title: Text('2. Jane Smith'),
            trailing: Text('18,500 Steps'),
          ),
          ListTile(
            title: Text('3. Bob Johnson'),
            trailing: Text('17,200 Steps'),
          ),
        ],
      ),
    );
  }
}
