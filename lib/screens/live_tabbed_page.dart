import 'package:flutter/material.dart';

import 'live_screen.dart';
import 'feed_screen.dart';
import 'explore_screen.dart';
import 'live_lounge_screen.dart';
// Placeholder for Live Lounge until implemented

class LiveTabbedPage extends StatefulWidget {
  const LiveTabbedPage({super.key});

  @override
  State<LiveTabbedPage> createState() => _LiveTabbedPageState();
}

class _LiveTabbedPageState extends State<LiveTabbedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Tab> _tabs = const [
    Tab(text: 'Live'),
    Tab(text: 'Live Lounge'),
    Tab(text: 'Feed'),
    Tab(text: 'Explorer'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PageStorage(
            bucket: _bucket,
            child: const LiveScreen(key: PageStorageKey('live')),
          ),
          PageStorage(
            bucket: _bucket,
            child: const LiveLoungeScreen(key: PageStorageKey('live_lounge')),
          ),
          PageStorage(
            bucket: _bucket,
            child: const FeedScreen(key: PageStorageKey('feed')),
          ),
          PageStorage(
            bucket: _bucket,
            child: const ExploreScreen(key: PageStorageKey('explorer')),
          ),
        ],
      ),
    );
  }
} 
