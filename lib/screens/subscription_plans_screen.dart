import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  static const routeName = '/subscription-plans';
  
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool _isLoading = false;
  
  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'free',
      name: 'Free',
      price: 0,
      period: 'Forever',
      features: [
        'Basic swiping and likes',
        'View messages',
        'Limited gifting (via ads)',
        'Profile management',
      ],
      limitations: [
        'No live streaming',
        'No premium gifts',
        'No video/phone calls',
        'Limited daily likes',
      ],
      color: Colors.grey,
      isRecommended: false,
    ),
    SubscriptionPlan(
      id: 'starter',
      name: 'Starter',
      price: 9.99,
      period: 'month',
      features: [
        'Everything in Free',
        'Live streaming access',
        'More daily likes',
        'Priority support',
        'Ad-free experience',
      ],
      limitations: [
        'No video/phone calls',
        'Limited premium gifts',
      ],
      color: AppColors.primary,
      isRecommended: true,
    ),
    SubscriptionPlan(
      id: 'gold',
      name: 'Gold',
      price: 19.99,
      period: 'month',
      features: [
        'Everything in Starter',
        'Video & phone calls',
        'Premium gifts access',
        'Super likes daily',
        'Advanced filters',
        'Read receipts',
      ],
      limitations: [],
      color: Colors.amber,
      isRecommended: false,
    ),
    SubscriptionPlan(
      id: 'platinum',
      name: 'Platinum',
      price: 39.99,
      period: 'month',
      features: [
        'Everything in Gold',
        'Unlimited everything',
        'VIP profile badge',
        'Priority customer support',
        'Exclusive features',
        'Advanced analytics',
      ],
      limitations: [],
      color: Colors.deepPurple,
      isRecommended: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Subscription Plans',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.diamond,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unlock Premium Features',
                        style: GoogleFonts.urbanist(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the plan that\'s right for you',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Plans
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final isCurrentPlan = plan.id == authProvider.subscriptionPlan;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: plan.isRecommended
                                ? AppColors.primary
                                : isCurrentPlan
                                    ? plan.color
                                    : AppColors.surfaceVariant,
                            width: plan.isRecommended || isCurrentPlan ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Recommended badge
                            if (plan.isRecommended)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'RECOMMENDED',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Plan content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Plan name and price
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.name,
                                            style: GoogleFonts.urbanist(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: plan.color,
                                            ),
                                          ),
                                          if (isCurrentPlan)
                                            Text(
                                              'Current Plan',
                                              style: GoogleFonts.urbanist(
                                                fontSize: 14,
                                                color: AppColors.success,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (plan.price > 0)
                                            Text(
                                              '\$${plan.price.toStringAsFixed(2)}',
                                              style: GoogleFonts.urbanist(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            )
                                          else
                                            Text(
                                              'FREE',
                                              style: GoogleFonts.urbanist(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          if (plan.price > 0)
                                            Text(
                                              'per ${plan.period}',
                                              style: GoogleFonts.urbanist(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Features
                                  ...plan.features.map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.success,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: GoogleFonts.urbanist(
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  
                                  // Limitations
                                  if (plan.limitations.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    ...plan.limitations.map((limitation) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.cancel,
                                            color: AppColors.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              limitation,
                                              style: GoogleFonts.urbanist(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Action button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isCurrentPlan
                                          ? null
                                          : () => _selectPlan(plan),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isCurrentPlan
                                            ? AppColors.surfaceVariant
                                            : plan.color,
                                        foregroundColor: isCurrentPlan
                                            ? AppColors.textSecondary
                                            : Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        isCurrentPlan
                                            ? 'Current Plan'
                                            : plan.id == 'free'
                                                ? 'Downgrade to Free'
                                                : 'Upgrade to ${plan.name}',
                                        style: GoogleFonts.urbanist(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Plans can be cancelled anytime. All features are immediately available after upgrade.',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  void _selectPlan(SubscriptionPlan plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // For testing purposes, immediately upgrade the user
      final success = await authProvider.upgradePlan(plan.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You\'re now upgraded to the ${plan.name} plan!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upgrade plan. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String period;
  final List<String> features;
  final List<String> limitations;
  final Color color;
  final bool isRecommended;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.limitations,
    required this.color,
    required this.isRecommended,
  });
} 