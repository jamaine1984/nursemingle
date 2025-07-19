import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/user_profile.dart';
import '../models/live_stream.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final trendingMoments = List<UserProfile>.from(appState.availableProfiles.map((user) => UserProfile.fromUser(user)))..shuffle();
    final trendingLives = List<LiveStream>.from(appState.liveStreams)..shuffle();
    final topUsers = List<UserProfile>.from(appState.availableProfiles.map((user) => UserProfile.fromUser(user)))..shuffle();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Explore', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Trending Moments', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: trendingMoments.length.clamp(0, 10),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final profile = trendingMoments[i];
                return GestureDetector(
                  onTap: () {
                    // Open profile detail
                    Navigator.pushNamed(context, '/profile', arguments: profile);
                  },
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(
                            profile.images.isNotEmpty ? profile.images[0] : '',
                            height: 100,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(profile.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Text('${profile.city}, ${profile.country}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Trending Live Events', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: trendingLives.length.clamp(0, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final live = trendingLives[i];
                return GestureDetector(
                  onTap: () {
                    // Open live event
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open live event: ${live.title}')),
                    );
                  },
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(
                            live.thumbnail,
                            height: 70,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(live.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Text('${live.viewers} viewers', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Top Users', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topUsers.length.clamp(0, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final user = topUsers[i];
                return GestureDetector(
                  onTap: () {
                    // Open profile detail
                    Navigator.pushNamed(context, '/profile', arguments: user);
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.images.isNotEmpty ? user.images[0] : ''),
                          radius: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(user.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(user.city, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
