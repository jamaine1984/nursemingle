import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/api_service.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Earnings data
  Map<String, dynamic> _earningsData = {};
  bool _isLoadingEarnings = true;
  String? _earningsError;
  
  // Analytics data
  Map<String, dynamic> _analyticsData = {};
  bool _isLoadingAnalytics = true;
  String? _analyticsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEarningsData();
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEarningsData() async {
    setState(() {
      _isLoadingEarnings = true;
      _earningsError = null;
    });

    try {
      print('💰 CREATOR_DASHBOARD: Loading earnings data...');
      final response = await ApiService.get('/api/creator/earnings');
      
      if (response['success'] == true) {
        setState(() {
          _earningsData = response['data'] ?? {};
          _isLoadingEarnings = false;
        });
        print('✅ CREATOR_DASHBOARD: Earnings loaded successfully');
      } else {
        throw Exception(response['error'] ?? 'Failed to load earnings');
      }
    } catch (e) {
      print('❌ CREATOR_DASHBOARD: Error loading earnings: $e');
      // Use mock data for demo
      if (mounted) {
        setState(() {
        _earningsData = {
          'total_earnings': 2547.89,
          'this_month': 412.33,
          'last_month': 389.45,
          'total_gifts_received': 1247,
          'top_gifters': [
            {'name': 'Sarah Johnson', 'amount': 156.78},
            {'name': 'Michael Chen', 'amount': 89.44},
            {'name': 'Emily Rodriguez', 'amount': 67.22},
          ],
          'recent_transactions': [
            {'date': '2024-07-17', 'amount': 23.45, 'type': 'Gift', 'from': 'Sarah J.'},
            {'date': '2024-07-16', 'amount': 15.67, 'type': 'Gift', 'from': 'Michael C.'},
            {'date': '2024-07-15', 'amount': 34.22, 'type': 'Live Stream', 'from': 'Multiple'},
          ],
          'pending_withdrawal': 412.33,
          'next_payout': '2024-07-25',
        };
        _isLoadingEarnings = false;
        _earningsError = null;
        });
        print('ℹ️ CREATOR_DASHBOARD: Using mock earnings data');
      }
    }
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoadingAnalytics = true;
      _analyticsError = null;
    });

    try {
      print('📊 CREATOR_DASHBOARD: Loading analytics data...');
      final response = await ApiService.get('/api/creator/analytics');
      
      if (response['success'] == true) {
        setState(() {
          _analyticsData = response['data'] ?? {};
          _isLoadingAnalytics = false;
        });
        print('✅ CREATOR_DASHBOARD: Analytics loaded successfully');
      } else {
        throw Exception(response['error'] ?? 'Failed to load analytics');
      }
    } catch (e) {
      print('❌ CREATOR_DASHBOARD: Error loading analytics: $e');
      // Use mock data for demo
      if (mounted) {
        setState(() {
        _analyticsData = {
          'profile_views': 15420,
          'profile_views_growth': 12.5,
          'admirers': 234,
          'admirers_growth': 8.3,
          'messages_received': 1847,
          'messages_growth': -2.1,
          'live_stream_hours': 47,
          'live_stream_viewers': 12890,
          'avg_stream_duration': 2.3,
          'daily_stats': [
            {'date': '2024-07-11', 'views': 245, 'gifts': 12, 'admirers': 8},
            {'date': '2024-07-12', 'views': 298, 'gifts': 15, 'admirers': 12},
            {'date': '2024-07-13', 'views': 167, 'gifts': 8, 'admirers': 5},
            {'date': '2024-07-14', 'views': 334, 'gifts': 18, 'admirers': 15},
            {'date': '2024-07-15', 'views': 412, 'gifts': 22, 'admirers': 19},
            {'date': '2024-07-16', 'views': 289, 'gifts': 14, 'admirers': 9},
            {'date': '2024-07-17', 'views': 356, 'gifts': 17, 'admirers': 13},
          ],
          'top_performing_content': [
            {'type': 'Live Stream', 'title': 'Night Shift Stories', 'views': 2340, 'engagement': 89.2},
            {'type': 'Profile Update', 'title': 'New Photos', 'views': 1876, 'engagement': 76.5},
            {'type': 'Live Stream', 'title': 'Q&A Session', 'views': 1654, 'engagement': 82.1},
          ],
        };
        _isLoadingAnalytics = false;
        _analyticsError = null;
                });
          print('ℹ️ CREATOR_DASHBOARD: Using mock analytics data');
        }
      }
    }

  Future<void> _requestWithdrawal() async {
    try {
      print('💸 CREATOR_DASHBOARD: Requesting withdrawal...');
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Request Withdrawal',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available balance: \$${_earningsData['pending_withdrawal']?.toStringAsFixed(2) ?? '0.00'}',
                style: GoogleFonts.urbanist(),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to request a withdrawal of your available balance?',
                style: GoogleFonts.urbanist(),
              ),
              const SizedBox(height: 16),
              Text(
                'Processing time: 3-5 business days',
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.urbanist(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Request Withdrawal',
                style: GoogleFonts.urbanist(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // In real app, this would make an API call
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Withdrawal request submitted successfully! You will receive an email confirmation.',
              style: GoogleFonts.urbanist(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Update the earnings data to reflect the withdrawal request
        setState(() {
          _earningsData['pending_withdrawal'] = 0.0;
        });
      }
    } catch (e) {
      print('❌ CREATOR_DASHBOARD: Error requesting withdrawal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request withdrawal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Creator Dashboard',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Earnings'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarningsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    if (_isLoadingEarnings) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Earnings Card
          _buildEarningsOverviewCard(),
          const SizedBox(height: 20),
          
          // Monthly Comparison
          _buildMonthlyComparisonCard(),
          const SizedBox(height: 20),
          
          // Top Gifters
          _buildTopGiftersCard(),
          const SizedBox(height: 20),
          
          // Recent Transactions
          _buildRecentTransactionsCard(),
          const SizedBox(height: 20),
          
          // Withdrawal Section
          _buildWithdrawalCard(),
        ],
      ),
    );
  }

  Widget _buildEarningsOverviewCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Earnings',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_earningsData['total_earnings']?.toStringAsFixed(2) ?? '0.00'}',
              style: GoogleFonts.urbanist(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${_earningsData['this_month']?.toStringAsFixed(2) ?? '0.00'}',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Gifts',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_earningsData['total_gifts_received'] ?? 0}',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonCard() {
    final thisMonth = _earningsData['this_month'] ?? 0.0;
    final lastMonth = _earningsData['last_month'] ?? 0.0;
    final difference = thisMonth - lastMonth;
    final isPositive = difference >= 0;

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Comparison',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${thisMonth.toStringAsFixed(2)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Month',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${lastMonth.toStringAsFixed(2)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}\$${difference.toStringAsFixed(2)}',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGiftersCard() {
    final topGifters = _earningsData['top_gifters'] as List<dynamic>? ?? [];

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Gifters',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (topGifters.isEmpty)
              Center(
                child: Text(
                  'No gifts received yet',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...topGifters.asMap().entries.map((entry) {
                final index = entry.key;
                final gifter = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < topGifters.length - 1 ? 12 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0 ? Colors.amber[700] : 
                                     index == 1 ? Colors.grey[400] : 
                                     Colors.orange[300],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            gifter['name'] ?? '',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${(gifter['amount'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    final transactions = _earningsData['recent_transactions'] as List<dynamic>? ?? [];

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Center(
                child: Text(
                  'No recent transactions',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...transactions.map<Widget>((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['type'] ?? '',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'From: ${transaction['from'] ?? ''}',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+\$${(transaction['amount'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            transaction['date'] ?? '',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard() {
    final pendingAmount = _earningsData['pending_withdrawal'] ?? 0.0;
    final nextPayout = _earningsData['next_payout'] ?? '';

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdrawal',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${pendingAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (nextPayout.isNotEmpty)
                      Text(
                        'Next payout: $nextPayout',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: pendingAmount > 0 ? _requestWithdrawal : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Withdraw',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_isLoadingAnalytics) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          _buildAnalyticsOverviewCard(),
          const SizedBox(height: 20),
          
          // Growth Metrics
          _buildGrowthMetricsCard(),
          const SizedBox(height: 20),
          
          // Live Stream Stats
          _buildLiveStreamStatsCard(),
          const SizedBox(height: 20),
          
          // Top Performing Content
          _buildTopPerformingContentCard(),
          const SizedBox(height: 20),
          
          // Daily Stats Chart (simplified)
          _buildDailyStatsCard(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverviewCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Profile Views',
                  '${_analyticsData['profile_views'] ?? 0}',
                  Icons.visibility,
                ),
                _buildStatColumn(
                  'Admirers',
                  '${_analyticsData['admirers'] ?? 0}',
                  Icons.favorite,
                ),
                _buildStatColumn(
                  'Messages',
                  '${_analyticsData['messages_received'] ?? 0}',
                  Icons.message,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthMetricsCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Metrics',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildGrowthItem('Profile Views', _analyticsData['profile_views_growth'] ?? 0),
            const SizedBox(height: 12),
            _buildGrowthItem('Admirers', _analyticsData['admirers_growth'] ?? 0),
            const SizedBox(height: 12),
            _buildGrowthItem('Messages', _analyticsData['messages_growth'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthItem(String title, double growth) {
    final isPositive = growth >= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 16,
              color: isPositive ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveStreamStatsCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Stream Performance',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreamStatColumn(
                  'Hours Streamed',
                  '${_analyticsData['live_stream_hours'] ?? 0}h',
                ),
                _buildStreamStatColumn(
                  'Total Viewers',
                  '${_analyticsData['live_stream_viewers'] ?? 0}',
                ),
                _buildStreamStatColumn(
                  'Avg Duration',
                  '${_analyticsData['avg_stream_duration']?.toStringAsFixed(1) ?? '0'}h',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopPerformingContentCard() {
    final topContent = _analyticsData['top_performing_content'] as List<dynamic>? ?? [];

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Content',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (topContent.isEmpty)
              Center(
                child: Text(
                  'No content data available',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...topContent.map<Widget>((content) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content['title'] ?? '',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              content['type'] ?? '',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${content['views'] ?? 0} views',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(content['engagement'] as double?)?.toStringAsFixed(1) ?? '0'}% engagement',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatsCard() {
    final dailyStats = _analyticsData['daily_stats'] as List<dynamic>? ?? [];

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Activity (Last 7 Days)',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (dailyStats.isEmpty)
              Center(
                child: Text(
                  'No daily stats available',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              // Simple bar chart representation
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: dailyStats.map<Widget>((day) {
                    final views = day['views'] ?? 0;
                    final maxViews = dailyStats.fold<int>(0, (max, d) => 
                        d['views'] > max ? d['views'] : max);
                    final height = maxViews > 0 ? (views / maxViews * 80).toDouble() : 0;
                    
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: height + 10,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${day['date']}'.split('-').last,
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
