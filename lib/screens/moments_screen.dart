import 'package:flutter/material.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key}) : super(key: key);

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  List<Map<String, dynamic>> _moments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    setState(() => _isLoading = true);
    try {
      // Mock data for development
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _moments = [
          {
            'id': '1',
            'title': 'My Day at the Hospital',
            'thumbnail': null,
            'duration': '00:30',
            'views': 25,
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          },
          {
            'id': '2',
            'title': 'Night Shift Adventures',
            'thumbnail': null,
            'duration': '01:15',
            'views': 42,
            'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading moments: $e')),
      );
    }
  }

  Future<void> _recordMoment() async {
    // Navigate to record video screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video recording feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Moments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _recordMoment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No moments yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Share your nursing moments with the community'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _recordMoment,
                        icon: const Icon(Icons.videocam),
                        label: const Text('Create First Moment'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _moments.length,
                  itemBuilder: (context, index) {
                    final moment = _moments[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: moment['thumbnail'] != null
                                  ? Image.network(
                                      moment['thumbnail'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.play_circle, size: 40),
                                    )
                                  : const Icon(Icons.play_circle, size: 40),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    moment['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${moment['views']} views • ${moment['duration']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordMoment,
        child: const Icon(Icons.videocam),
      ),
    );
  }
} 
