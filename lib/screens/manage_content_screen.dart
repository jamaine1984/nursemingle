import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/api_service.dart';
import 'package:intl/intl.dart';

class ManageContentScreen extends StatefulWidget {
  const ManageContentScreen({Key? key}) : super(key: key);

  @override
  State<ManageContentScreen> createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  List<ContentItem> _contentItems = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, video, photo, live
  
  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('/api/creator/content');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> contentData = response['data'] ?? [];
        
        setState(() {
          _contentItems = contentData.map((item) => ContentItem.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        // Use mock data if backend is not available
        _loadMockData();
      }
    } catch (e) {
      print('Error loading content: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      _contentItems = [
        ContentItem(
          id: '1',
          type: 'live',
          title: 'Night Shift Stories - Live Replay',
          thumbnail: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
          uploadTime: DateTime.now().subtract(const Duration(hours: 2)),
          views: 1567,
          gifts: 45,
          duration: const Duration(hours: 1, minutes: 23),
        ),
        ContentItem(
          id: '2',
          type: 'video',
          title: 'Quick Tips for New Nurses',
          thumbnail: 'https://images.unsplash.com/photo-1559563458-527698bf5295',
          uploadTime: DateTime.now().subtract(const Duration(days: 1)),
          views: 3421,
          gifts: 12,
          duration: const Duration(seconds: 28),
        ),
        ContentItem(
          id: '3',
          type: 'photo',
          title: 'My Nursing Station Setup',
          thumbnail: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
          uploadTime: DateTime.now().subtract(const Duration(days: 3)),
          views: 892,
          gifts: 5,
        ),
      ];
      _isLoading = false;
    });
  }

  List<ContentItem> get _filteredContent {
    if (_selectedFilter == 'all') return _contentItems;
    return _contentItems.where((item) => item.type == _selectedFilter).toList();
  }

  Future<void> _deleteContent(ContentItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content?'),
        content: Text('Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.delete('/api/creator/content/${item.id}');
        setState(() {
          _contentItems.removeWhere((content) => content.id == item.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete content: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _previewContent(ContentItem item) {
    // TODO: Implement preview functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Previewing: ${item.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Manage Content',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Videos', 'video'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Photos', 'photo'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Live Streams', 'live'),
                ],
              ),
            ),
          ),
          
          // Stats summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Total Content',
                  _contentItems.length.toString(),
                  Icons.content_copy,
                ),
                _buildStatColumn(
                  'Total Views',
                  _formatCount(_contentItems.fold(0, (sum, item) => sum + item.views)),
                  Icons.visibility,
                ),
                _buildStatColumn(
                  'Total Gifts',
                  _formatCount(_contentItems.fold(0, (sum, item) => sum + item.gifts)),
                  Icons.card_giftcard,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Content list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContent.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.content_paste_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'all'
                                  ? 'No content uploaded yet'
                                  : 'No ${_selectedFilter}s uploaded yet',
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredContent.length,
                        itemBuilder: (context, index) {
                          return _buildContentItem(_filteredContent[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.urbanist(
        color: isSelected ? Colors.white : AppColors.text,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContentItem(ContentItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _previewContent(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.network(
                      item.thumbnail,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.surface,
                          child: Icon(
                            _getIconForType(item.type),
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                    // Type badge
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getColorForType(item.type),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded ${_formatDate(item.uploadTime)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStat(Icons.visibility, item.views),
                        const SizedBox(width: 16),
                        _buildStat(Icons.card_giftcard, item.gifts),
                        if (item.duration != null) ...[
                          const SizedBox(width: 16),
                          _buildStat(Icons.timer, _formatDuration(item.duration!)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'preview':
                      _previewContent(item);
                      break;
                    case 'delete':
                      _deleteContent(item);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 20),
                        SizedBox(width: 8),
                        Text('Preview'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          value is int ? _formatCount(value) : value.toString(),
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'video':
        return Icons.video_library;
      case 'photo':
        return Icons.photo;
      case 'live':
        return Icons.live_tv;
      default:
        return Icons.content_copy;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'video':
        return AppColors.secondary;
      case 'photo':
        return AppColors.info;
      case 'live':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inHours < 24) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

class ContentItem {
  final String id;
  final String type;
  final String title;
  final String thumbnail;
  final DateTime uploadTime;
  final int views;
  final int gifts;
  final Duration? duration;

  ContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.thumbnail,
    required this.uploadTime,
    required this.views,
    required this.gifts,
    this.duration,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'video',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      uploadTime: json['upload_time'] != null 
          ? DateTime.parse(json['upload_time']) 
          : DateTime.now(),
      views: json['views'] ?? 0,
      gifts: json['gifts'] ?? 0,
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
    );
  }
} 