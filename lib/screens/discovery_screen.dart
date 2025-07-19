import 'package:flutter/material.dart';
import '../services/discovery_service.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<User> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await DiscoveryService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  void _likeUser(User user) async {
    await DiscoveryService.likeUser(user.id);
    _removeUser(user);
  }

  void _passUser(User user) async {
    await DiscoveryService.passUser(user.id);
    _removeUser(user);
  }

  void _superLikeUser(User user) async {
    await DiscoveryService.superLikeUser(user.id);
    _removeUser(user);
  }

  void _removeUser(User user) {
    setState(() {
      _users.remove(user);
    });
    if (_users.isEmpty) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No more users to discover'))
              : Stack(
                  children: [
                    for (int i = 0; i < _users.length; i++)
                      Positioned.fill(
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: AppColors.background,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person, size: 100),
                                        Text(
                                          _users[i].name,
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                        Text('Age: ${_users[i].age}'),
                                        if (_users[i].profession != null) Text(_users[i].profession!),
                                        if (_users[i].location != null) Text(_users[i].location!),
                                        if (_users[i].bio != null) 
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(_users[i].bio!),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FloatingActionButton(
                                      heroTag: 'pass_${_users[i].id}',
                                      onPressed: () => _passUser(_users[i]),
                                      backgroundColor: Colors.red,
                                      child: const Icon(Icons.close, color: Colors.white),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'super_${_users[i].id}',
                                      onPressed: () => _superLikeUser(_users[i]),
                                      backgroundColor: Colors.blue,
                                      child: const Icon(Icons.star, color: Colors.white),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'like_${_users[i].id}',
                                      onPressed: () => _likeUser(_users[i]),
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.favorite, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
} 
