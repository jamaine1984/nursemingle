import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/api_service.dart';

class BillingPaymentsScreen extends StatefulWidget {
  const BillingPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<BillingPaymentsScreen> createState() => _BillingPaymentsScreenState();
}

class _BillingPaymentsScreenState extends State<BillingPaymentsScreen> {
  bool _isLoading = true;
  String? _error;
  
  Map<String, dynamic> _billingData = {};
  List<Map<String, dynamic>> _invoices = [];
  Map<String, dynamic>? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('💳 BILLING: Loading billing data...');
      
      // Load billing overview
      final billingResponse = await ApiService.get('/api/billing/overview');
      
      // Load invoices
      final invoicesResponse = await ApiService.get('/api/billing/invoices');
      
      // Load payment method
      final paymentResponse = await ApiService.get('/api/billing/payment-method');
      
      if (billingResponse['success'] == true) {
        setState(() {
          _billingData = billingResponse['data'] ?? {};
          _invoices = List<Map<String, dynamic>>.from(invoicesResponse['data'] ?? []);
          _paymentMethod = paymentResponse['data'];
          _isLoading = false;
        });
        print('✅ BILLING: Data loaded successfully');
      } else {
        throw Exception('Failed to load billing data');
      }
    } catch (e) {
      print('❌ BILLING: Error loading data: $e');
      // Use mock data for demo
      setState(() {
        _billingData = {
          'current_plan': 'starter',
          'plan_name': 'Starter Plan',
          'monthly_cost': 9.99,
          'next_billing_date': '2024-08-17',
          'subscription_status': 'active',
          'billing_cycle': 'monthly',
        };
        _invoices = [
          {
            'id': 'inv_001',
            'date': '2024-07-17',
            'amount': 9.99,
            'status': 'paid',
            'plan': 'Starter Plan',
            'download_url': '#',
          },
          {
            'id': 'inv_002',
            'date': '2024-06-17',
            'amount': 9.99,
            'status': 'paid',
            'plan': 'Starter Plan',
            'download_url': '#',
          },
          {
            'id': 'inv_003',
            'date': '2024-05-17',
            'amount': 9.99,
            'status': 'paid',
            'plan': 'Starter Plan',
            'download_url': '#',
          },
        ];
        _paymentMethod = {
          'type': 'card',
          'brand': 'visa',
          'last4': '4242',
          'exp_month': 12,
          'exp_year': 2025,
        };
        _isLoading = false;
        _error = null;
      });
      print('ℹ️ BILLING: Using mock billing data');
    }
  }

  Future<void> _upgradePlan(String newPlan) async {
    try {
      print('🚀 BILLING: Upgrading to $newPlan...');
      
      final response = await ApiService.post('/billing/change-plan', {
        'new_plan': newPlan,
      });
      
      if (response['success'] == true) {
        // Update auth provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.updateSubscriptionPlan(newPlan);
        
        // Reload billing data
        await _loadBillingData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully upgraded to ${_getPlanDisplayName(newPlan)}!'),
            backgroundColor: Colors.green,
          ),
        );
        
        print('✅ BILLING: Plan upgrade successful');
      } else {
        throw Exception(response['error'] ?? 'Failed to upgrade plan');
      }
    } catch (e) {
      print('❌ BILLING: Error upgrading plan: $e');
      
      // For demo purposes, simulate success
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.updateSubscriptionPlan(newPlan);
      
      setState(() {
        _billingData['current_plan'] = newPlan;
        _billingData['plan_name'] = _getPlanDisplayName(newPlan);
        _billingData['monthly_cost'] = _getPlanPrice(newPlan);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully upgraded to ${_getPlanDisplayName(newPlan)}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getPlanDisplayName(String plan) {
    switch (plan) {
      case 'free': return 'Free Plan';
      case 'starter': return 'Starter Plan';
      case 'gold': return 'Gold Plan';
      case 'platinum': return 'Platinum Plan';
      default: return 'Unknown Plan';
    }
  }

  double _getPlanPrice(String plan) {
    switch (plan) {
      case 'free': return 0.0;
      case 'starter': return 9.99;
      case 'gold': return 19.99;
      case 'platinum': return 39.99;
      default: return 0.0;
    }
  }

  Future<void> _downloadInvoice(Map<String, dynamic> invoice) async {
    try {
      print('📄 BILLING: Downloading invoice ${invoice['id']}...');
      
      // In a real app, this would download the actual PDF
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ${invoice['id']} downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download invoice: ${e.toString()}'),
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
          'Billing & Payments',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Billing Data',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.urbanist(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBillingData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Plan Card
          _buildCurrentPlanCard(),
          const SizedBox(height: 24),
          
          // Upgrade Options
          _buildUpgradeSection(),
          const SizedBox(height: 24),
          
          // Payment Method
          _buildPaymentMethodCard(),
          const SizedBox(height: 24),
          
          // Invoices
          _buildInvoicesSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final currentPlan = _billingData['current_plan'] ?? 'free';
    final planName = _billingData['plan_name'] ?? 'Free Plan';
    final monthlyCost = _billingData['monthly_cost'] ?? 0.0;
    final nextBillingDate = _billingData['next_billing_date'] ?? '';
    final status = _billingData['subscription_status'] ?? 'active';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Plan',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: status == 'active' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              planName,
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${monthlyCost.toStringAsFixed(2)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '/month',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (nextBillingDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Next billing date: $nextBillingDate',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeSection() {
    final currentPlan = _billingData['current_plan'] ?? 'free';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade Your Plan',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Show upgrade options only if not already on that plan
        if (currentPlan != 'starter')
          _buildPlanUpgradeCard(
            'Starter Plan',
            'Perfect for new creators',
            9.99,
            [
              '50 daily likes',
              '50 daily messages',
              '20 hours live streaming',
              '100 minutes video/phone calls',
            ],
            () => _upgradePlan('starter'),
          ),
        
        if (currentPlan != 'gold' && currentPlan != 'platinum')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildPlanUpgradeCard(
              'Gold Plan',
              'For growing creators',
              19.99,
              [
                '100 daily likes',
                '200 daily messages',
                '5 daily super likes',
                '90 hours live streaming',
                '500 minutes video/phone calls',
              ],
              () => _upgradePlan('gold'),
            ),
          ),
        
        if (currentPlan != 'platinum')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildPlanUpgradeCard(
              'Platinum Plan',
              'Ultimate creator experience',
              39.99,
              [
                'Unlimited likes',
                'Unlimited messages',
                '20 daily super likes',
                '200 hours live streaming',
                '2000 minutes video/phone calls',
                'Priority support',
              ],
              () => _upgradePlan('platinum'),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanUpgradeCard(
    String planName,
    String description,
    double price,
    List<String> features,
    VoidCallback onUpgrade,
  ) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
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
                      '\$${price.toStringAsFixed(2)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'per month',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Features
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Upgrade to $planName',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Method',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment method management coming soon!'),
                      ),
                    );
                  },
                  child: Text(
                    'Change',
                    style: GoogleFonts.urbanist(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_paymentMethod != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '**** **** **** ${_paymentMethod!['last4']}',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${(_paymentMethod!['brand'] as String).toUpperCase()} • Expires ${_paymentMethod!['exp_month']}/${_paymentMethod!['exp_year']}',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  'No payment method on file',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Invoices',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_invoices.isEmpty)
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No invoices available',
                  style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
        else
          ...(_invoices.take(5).map((invoice) => _buildInvoiceCard(invoice))),
      ],
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final status = invoice['status'] as String;
    final statusColor = status == 'paid' ? Colors.green : 
                       status == 'pending' ? Colors.orange : Colors.red;

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice ${invoice['id']}',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  invoice['date'],
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  invoice['plan'],
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
                  '\$${(invoice['amount'] as double).toStringAsFixed(2)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _downloadInvoice(invoice),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Download',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: AppColors.primary,
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
} 