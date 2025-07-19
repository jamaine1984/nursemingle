import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'billing_payments_screen.dart';
import 'creator_dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  double _maxDistance = 50.0;
  RangeValues _ageRange = const RangeValues(21, 65);

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Settings
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Account',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      try {
                        Navigator.pushNamed(context, '/edit_profile');
                      } catch (e) {
                        print('Error navigating to edit profile: $e');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('Blocked Users'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      try {
                        Navigator.pushNamed(context, '/blocked_users');
                      } catch (e) {
                        print('Error navigating to blocked users: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Monetization Settings (for creators)
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Monetization',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.monetization_on),
                    title: const Text('Creator Earnings'),
                    subtitle: const Text('View your monetization details'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatorDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Revenue Analytics'),
                    subtitle: const Text('Track your earnings and performance'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatorDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Subscription Settings
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Subscription',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.diamond),
                    title: const Text('Subscription Plans'),
                    subtitle: const Text('Upgrade for premium features'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showSubscriptionPage(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Billing & Payments'),
                    subtitle: const Text('Manage your payment methods'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BillingPaymentsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Notifications
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive match and message notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Discovery Settings
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Discovery Settings',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Location Services'),
                    subtitle: const Text('Use location for better matches'),
                    value: _locationEnabled,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _locationEnabled = value;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Maximum Distance'),
                    subtitle: Text('${_maxDistance.round()} miles'),
                  ),
                  Slider(
                    value: _maxDistance,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${_maxDistance.round()} miles',
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _maxDistance = value;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Age Range'),
                    subtitle: Text('${_ageRange.start.round()} - ${_ageRange.end.round()} years'),
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 70,
                    divisions: 52,
                    labels: RangeLabels(
                      _ageRange.start.round().toString(),
                      _ageRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      if (mounted) {
                        setState(() {
                          _ageRange = values;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () async {
                    try {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    } catch (e) {
                      print('Error during logout: $e');
                    }
                  },
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error in SettingsScreen build: $e');
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: Text('Error loading settings: $e'),
        ),
      );
    }
  }

  void _showMonetizationPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creator Monetization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Earning Potential by Subscription Tier',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Free Tier
              _buildTierCard(
                'Free Tier',
                'No monetization features',
                '0% of ad revenue',
                '0% of premium gifts',
                Colors.grey,
              ),
              
              // Starter Plan
              _buildTierCard(
                'Starter Plan',
                'Basic monetization features',
                '30% of interstitial ads on live streams',
                '30% of premium gifts',
                Colors.blue,
              ),
              
              // Gold Plan
              _buildTierCard(
                'Gold Plan',
                'Advanced monetization features',
                '70% of ads on live streams',
                '70% of premium gifts',
                Colors.amber,
              ),
              
              // Platinum Plan
              _buildTierCard(
                'Platinum Plan',
                'Premium monetization features',
                '100% of ads on live streams',
                '100% of premium gifts (IAP only)',
                Colors.purple,
              ),
              
              const SizedBox(height: 16),
              Text(
                'Note: Premium gifts are only available through in-app purchases (IAP) for Platinum users.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSubscriptionPage(context);
            },
            child: const Text('Upgrade Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(String title, String description, String adRevenue, String giftRevenue, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text('• $adRevenue', style: const TextStyle(fontSize: 12)),
          Text('• $giftRevenue', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showSubscriptionPage(BuildContext context) {
    Navigator.pushNamed(context, '/subscription-plans');
  }
  
  void _showSubscriptionPageOld(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Plans'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Free Tier
              _buildSubscriptionCard(
                'Free',
                '\$0/month',
                [
                  'Basic app features',
                  'Limited likes per day',
                  'Basic profile',
                  'No monetization',
                ],
                Colors.grey,
                false,
              ),
              
              // Starter Plan
              _buildSubscriptionCard(
                'Starter',
                '\$9.99/month',
                [
                  'Unlimited likes',
                  'Super likes',
                  'Basic monetization (30%)',
                  'Priority support',
                ],
                Colors.blue,
                false,
              ),
              
              // Gold Plan
              _buildSubscriptionCard(
                'Gold',
                '\$19.99/month',
                [
                  'All Starter features',
                  'Advanced monetization (70%)',
                  'Premium profile features',
                  'Advanced analytics',
                ],
                Colors.amber,
                true, // Popular
              ),
              
              // Platinum Plan
              _buildSubscriptionCard(
                'Platinum',
                '\$29.99/month',
                [
                  'All Gold features',
                  'Maximum monetization (100%)',
                  'Exclusive premium gifts',
                  'VIP support',
                ],
                Colors.purple,
                false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(String title, String price, List<String> features, Color color, bool isPopular) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? color : color.withOpacity(0.3),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Subscription to $title plan coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Choose $title'),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 
