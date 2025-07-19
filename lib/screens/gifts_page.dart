import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftsPage extends StatelessWidget {
  const GiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gifts', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.card_giftcard), text: 'My Gift Shelf'),
              Tab(icon: Icon(Icons.inbox), text: 'Received Gifts'),
              Tab(icon: Icon(Icons.inventory), text: 'Gift Inventory'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyGiftShelfTab(),
            _ReceivedGiftsTab(),
            _GiftInventoryTab(),
          ],
        ),
      ),
    );
  }
}

class _MyGiftShelfTab extends StatelessWidget {
  const _MyGiftShelfTab();
  @override
  Widget build(BuildContext context) {
    // 100 free + 100 premium gifts
    final gifts = List.generate(100, (i) => {'name': 'Free Gift ${i+1}', 'premium': false}) +
        List.generate(100, (i) => {'name': 'Premium Gift ${i+1}', 'premium': true});
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, i) {
        final gift = gifts[i];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: (gift['premium'] as bool) ? Colors.amber[50] : Colors.blue[50],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, size: 36, color: (gift['premium'] as bool) ? Colors.amber : Colors.blue),
                const SizedBox(height: 8),
                Text(gift['name'] as String,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (gift['premium'] as bool)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Premium', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReceivedGiftsTab extends StatelessWidget {
  const _ReceivedGiftsTab();
  @override
  Widget build(BuildContext context) {
    // Received/sent gifts
    final received = List.generate(10, (i) => {'name': 'Gift ${i+1}', 'from': 'User${i+1}', 'type': 'received'});
    final sent = List.generate(5, (i) => {'name': 'Gift ${i+1}', 'to': 'User${i+11}', 'type': 'sent'});
    final all = [...received, ...sent];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: all.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final gift = all[i];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Icon(Icons.card_giftcard, color: Colors.purple, size: 32),
            title: Text(gift['name'] as String, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            subtitle: Text(gift['type'] == 'received' ? 'From: ${gift['from']}' : 'To: ${gift['to']}'),
            trailing: Icon(gift['type'] == 'received' ? Icons.download : Icons.upload, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class _GiftInventoryTab extends StatelessWidget {
  const _GiftInventoryTab();
  @override
  Widget build(BuildContext context) {
    // Inventory
    final inventory = List.generate(20, (i) => {'name': 'Owned Gift ${i+1}', 'premium': i % 2 == 0});
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: inventory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final gift = inventory[i];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: (gift['premium'] as bool) ? Colors.amber[50] : Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.card_giftcard, color: (gift['premium'] as bool) ? Colors.amber : Colors.blue, size: 32),
            title: Text(gift['name'] as String, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            subtitle: Text((gift['premium'] as bool) ? 'Premium' : 'Free'),
            trailing: const Icon(Icons.inventory, color: Colors.grey),
          ),
        );
      },
    );
  }
} 
