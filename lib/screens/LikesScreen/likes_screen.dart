import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LikesScreen extends StatefulWidget {
  static const routeName = '/likes';
  const LikesScreen({super.key});
  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Mock data for demonstration
  List<Map<String, dynamic>> likes = [
    {
      'imageUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
      'displayName': 'Emily',
      'age': 29,
      'state': 'California',
      'jobTitle': 'Nurse',
      'bio': 'Loves hiking and coffee.',
      'isNew': true,
    },
    {
      'imageUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
      'displayName': 'James',
      'age': 34,
      'state': 'Texas',
      'jobTitle': 'Paramedic',
      'bio': 'Dog dad. BBQ enthusiast.',
      'isNew': false,
    },
    {
      'imageUrl': 'https://randomuser.me/api/portraits/women/3.jpg',
      'displayName': 'Sophia',
      'age': 27,
      'state': 'New York',
      'jobTitle': 'ER Doctor',
      'bio': 'Runner. Bookworm.',
      'isNew': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Likes', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFFFFE5B4),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: likes.isEmpty
          ? Center(child: Text('No new likes yet.', style: GoogleFonts.poppins(fontSize: 18)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: likes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final like = likes[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 4,
                  color: theme.colorScheme.surface,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(like['imageUrl']),
                          radius: 28,
                        ),
                        if (like['isNew'])
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fiber_new, size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      '${like['displayName']}, ${like['age']}',
                      style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16),
                            const SizedBox(width: 2),
                            Text(like['state'], style: GoogleFonts.inter(fontSize: 14)),
                            const SizedBox(width: 8),
                            const Icon(Icons.work_outline, size: 16),
                            const SizedBox(width: 2),
                            Text(like['jobTitle'], style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(like['bio'], style: GoogleFonts.inter(fontSize: 15)),
                      ],
                    ),
                    trailing: like['isNew']
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('New', style: GoogleFonts.poppins(color: theme.colorScheme.primary)),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                );
              },
            ),
    );
  }
} 
