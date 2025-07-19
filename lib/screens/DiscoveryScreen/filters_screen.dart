import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart'; // Added import for AppColors

class FiltersScreen extends StatefulWidget {
  static const routeName = '/filters';
  const FiltersScreen({super.key});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String gender = 'Any';
  RangeValues ageRange = const RangeValues(18, 100);
  String state = 'Any';
  String city = '';
  double distance = 100.0;
  bool verifiedOnly = false;
  String planType = 'Any';
  String country = 'Any';
  final List<String> countries = [
    'Any', 'United States', 'Canada', 'United Kingdom', 'Australia', 'Germany', 'France', 'Italy', 'Spain',
    'Brazil', 'Mexico', 'India', 'China', 'Japan', 'South Korea', 'Russia', 'Turkey', 'Netherlands',
    'Sweden', 'Norway', 'Denmark', 'Finland', 'Poland', 'Switzerland', 'Austria', 'Belgium',
    'Ireland', 'Portugal', 'Greece', 'Czech Republic', 'Hungary', 'Romania', 'Bulgaria', 'Croatia',
    'Slovakia', 'Slovenia', 'Serbia', 'Ukraine', 'Belarus', 'Estonia', 'Latvia', 'Lithuania',
    'Israel', 'Egypt', 'South Africa', 'Nigeria', 'Kenya', 'Morocco', 'Argentina', 'Chile',
    'Colombia', 'Peru', 'Venezuela', 'Philippines', 'Indonesia', 'Malaysia', 'Singapore',
    'Thailand', 'Vietnam', 'New Zealand', 'Saudi Arabia', 'UAE', 'Qatar', 'Kuwait', 'Pakistan',
    'Bangladesh', 'Sri Lanka', 'Nepal', 'Myanmar', 'Cambodia', 'Laos', 'Mongolia', 'Kazakhstan',
    'Uzbekistan', 'Georgia', 'Armenia', 'Azerbaijan', 'Jordan', 'Lebanon', 'Iraq', 'Iran',
    'Afghanistan', 'Yemen', 'Oman', 'Bahrain', 'Iceland', 'Luxembourg', 'Liechtenstein', 'Monaco',
    'Andorra', 'San Marino', 'Malta', 'Cyprus', 'Other...'
  ];
  bool worldExplorer = false;
  String explorerCountry = 'Any';
  String explorerRegion = '';
  String explorerCity = '';

  final List<String> genders = ['Any', 'Male', 'Female', 'Other'];
  final List<String> states = [
    'Any', 'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS',
    'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC',
    'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
  ];
  final List<String> planTypes = ['Any', 'Free', 'Starter', 'Gold'];

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      gender = prefs.getString('filter_gender') ?? 'Any';
      ageRange = RangeValues(
        prefs.getDouble('filter_ageMin') ?? 18,
        prefs.getDouble('filter_ageMax') ?? 100,
      );
      state = prefs.getString('filter_state') ?? 'Any';
      city = prefs.getString('filter_city') ?? '';
      distance = prefs.getDouble('filter_distance') ?? 100.0;
      verifiedOnly = prefs.getBool('filter_verified') ?? false;
      planType = prefs.getString('filter_planType') ?? 'Any';
      country = prefs.getString('filter_country') ?? 'Any';
      worldExplorer = prefs.getBool('filter_worldExplorer') ?? false;
      explorerCountry = prefs.getString('filter_explorerCountry') ?? 'Any';
      explorerRegion = prefs.getString('filter_explorerRegion') ?? '';
      explorerCity = prefs.getString('filter_explorerCity') ?? '';
    });
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filter_gender', gender);
    await prefs.setDouble('filter_ageMin', ageRange.start);
    await prefs.setDouble('filter_ageMax', ageRange.end);
    await prefs.setString('filter_state', state);
    await prefs.setString('filter_city', city);
    await prefs.setDouble('filter_distance', distance);
    await prefs.setBool('filter_verified', verifiedOnly);
    await prefs.setString('filter_planType', planType);
    await prefs.setString('filter_country', country);
    await prefs.setBool('filter_worldExplorer', worldExplorer);
    await prefs.setString('filter_explorerCountry', explorerCountry);
    await prefs.setString('filter_explorerRegion', explorerRegion);
    await prefs.setString('filter_explorerCity', explorerCity);
  }

  void _applyFilters() async {
    await _saveFilters();
    final filters = <String, String>{};
    if (gender != 'Any') filters['gender'] = gender;
    filters['ageMin'] = ageRange.start.round().toString();
    filters['ageMax'] = ageRange.end.round().toString();
    if (state != 'Any') filters['state'] = state;
    if (city.isNotEmpty) filters['city'] = city;
    filters['distance'] = distance.round().toString();
    if (verifiedOnly) filters['verified'] = 'true';
    if (planType != 'Any') filters['planType'] = planType;
    if (country != 'Any') filters['country'] = country;
    if (worldExplorer) {
      if (explorerCountry != 'Any') filters['country'] = explorerCountry;
      if (explorerRegion.isNotEmpty) filters['region'] = explorerRegion;
      if (explorerCity.isNotEmpty) filters['city'] = explorerCity;
      filters['worldExplorer'] = 'true';
    }
    Navigator.pop(context, filters);
  }

  void _resetFilters() async {
    setState(() {
      gender = 'Any';
      ageRange = const RangeValues(18, 100);
      state = 'Any';
      city = '';
      distance = 100.0;
      verifiedOnly = false;
      planType = 'Any';
      country = 'Any';
      worldExplorer = false;
      explorerCountry = 'Any';
      explorerRegion = '';
      explorerCity = '';
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('filter_gender');
    await prefs.remove('filter_ageMin');
    await prefs.remove('filter_ageMax');
    await prefs.remove('filter_state');
    await prefs.remove('filter_city');
    await prefs.remove('filter_distance');
    await prefs.remove('filter_verified');
    await prefs.remove('filter_planType');
    await prefs.remove('filter_country');
    await prefs.remove('filter_worldExplorer');
    await prefs.remove('filter_explorerCountry');
    await prefs.remove('filter_explorerRegion');
    await prefs.remove('filter_explorerCity');
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Filters', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: Colors.grey[700])),
        backgroundColor: const Color(0xFFFFE5B4),
        foregroundColor: Colors.grey[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[700]),
            tooltip: 'Reset Filters',
            onPressed: _resetFilters,
            splashRadius: 22,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ListView(
          children: [
            Row(
              children: [
                Switch(
                  value: worldExplorer,
                  onChanged: (val) => setState(() => worldExplorer = val),
                  activeColor: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                Text('World Explorer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[700])),
              ],
            ),
            if (worldExplorer) ...[
              const SizedBox(height: 12),
              Text('Explore Country', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    value: explorerCountry,
                    isExpanded: true,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(16),
                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
                    items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])))).toList(),
                    onChanged: (val) => setState(() => explorerCountry = val!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Region/State (optional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter region/state',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                controller: TextEditingController(text: explorerRegion),
                onChanged: (val) => setState(() => explorerRegion = val),
              ),
              const SizedBox(height: 12),
              Text('City (optional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter city',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                controller: TextEditingController(text: explorerCity),
                onChanged: (val) => setState(() => explorerCity = val),
              ),
              const SizedBox(height: 24),
            ],
            Text('Gender', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: gender,
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
                  items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])))).toList(),
                  onChanged: (val) => setState(() => gender = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Age Range: ${ageRange.start.round()} - ${ageRange.end.round()}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            RangeSlider(
              values: ageRange,
              min: 18,
              max: 100,
              divisions: 82,
              labels: RangeLabels('${ageRange.start.round()}', '${ageRange.end.round()}'),
              onChanged: (val) => setState(() => ageRange = val),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 24),
            Text('State', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: state,
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
                  items: states.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])))).toList(),
                  onChanged: (val) => setState(() => state = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('City', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter city',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              controller: TextEditingController(text: city),
              onChanged: (val) => city = val,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Text('Distance Radius: ${distance.round()} miles', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            Slider(
              value: distance,
              min: 0,
              max: 5000,
              divisions: 100,
              label: '${distance.round()} mi',
              onChanged: (val) => setState(() => distance = val),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Verified Only', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
                Switch(
                  value: verifiedOnly,
                  onChanged: (val) => setState(() => verifiedOnly = val),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Plan Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: planType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
                  items: planTypes.map((p) => DropdownMenuItem(value: p, child: Text(p, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])))).toList(),
                  onChanged: (val) => setState(() => planType = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Country', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: country,
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
                  items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])))).toList(),
                  onChanged: (val) => setState(() => country = val!),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                  elevation: 2,
                ),
                label: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
