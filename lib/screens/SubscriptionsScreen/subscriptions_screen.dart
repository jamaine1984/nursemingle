import 'package:flutter/material.dart';

class SubscriptionsScreen extends StatelessWidget {
  static const routeName = '/subscriptions';

  const SubscriptionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: const Center(child: Text('Subscriptions Screen Placeholder')),
    );
  }
} 
