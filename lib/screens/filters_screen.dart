import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_colors.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({Key? key}) : super(key: key);

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String? _selectedGender;
  RangeValues _ageRange = const RangeValues(18, 65);
  String? _selectedCountry;
  String? _selectedProfession;
  double _maxDistance = 20000; // Up to 20,000 miles as specified

  final List<String> _genders = ['Male', 'Female', 'Non-binary', 'All'];
  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany',
    'France',
    'Spain',
    'Italy',
    'Netherlands',
    'Sweden',
    'Norway',
    'Denmark',
    'Philippines',
    'India',
    'Japan',
    'South Korea',
    'Brazil',
    'Mexico',
    'Argentina',
    'South Africa',
  ];
  
  final List<String> _professions = [
    'Registered Nurse',
    'Licensed Practical Nurse',
    'Nurse Practitioner',
    'Certified Nursing Assistant',
    'Nurse Anesthetist',
    'Nurse Midwife',
    'Clinical Nurse Specialist',
    'Charge Nurse',
    'ICU Nurse',
    'Emergency Room Nurse',
    'Operating Room Nurse',
    'Pediatric Nurse',
    'Psychiatric Nurse',
    'Oncology Nurse',
    'Cardiac Nurse',
    'Travel Nurse',
    'School Nurse',
    'Home Health Nurse',
    'Public Health Nurse',
    'Nurse Educator',
    'Nurse Administrator',
    'Doctor',
    'Physician Assistant',
    'Medical Technician',
    'Pharmacy Technician',
    'Physical Therapist',
    'Occupational Therapist',
    'Respiratory Therapist',
    'Medical Assistant',
    'Healthcare Administrator',
    'Other Healthcare Professional',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    
    setState(() {
      _selectedGender = appStateProvider.genderFilter;
      _selectedCountry = appStateProvider.countryFilter;
      _selectedProfession = appStateProvider.professionFilter;
      _maxDistance = appStateProvider.maxDistanceFilter ?? 20000;
      
      // Load age filter
      if (appStateProvider.minAgeFilter != null && appStateProvider.maxAgeFilter != null) {
        _ageRange = RangeValues(
          appStateProvider.minAgeFilter!.toDouble(),
          appStateProvider.maxAgeFilter!.toDouble(),
        );
      }
    });
  }

  void _applyFilters() {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    
    appStateProvider.setGenderFilter(_selectedGender);
    appStateProvider.setAgeFilter(_ageRange.start.round(), _ageRange.end.round());
    appStateProvider.setCountryFilter(_selectedCountry);
    appStateProvider.setProfessionFilter(_selectedProfession);
    appStateProvider.setDistanceFilter(_maxDistance);
    
    // Reload profiles with new filters
    appStateProvider.loadDiscoverProfiles(refresh: true);
    
    Navigator.pop(context);
  }

  void _clearFilters() {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    
    setState(() {
      _selectedGender = null;
      _ageRange = const RangeValues(18, 65);
      _selectedCountry = null;
      _selectedProfession = null;
      _maxDistance = 20000;
    });
    
    appStateProvider.clearFilters();
    appStateProvider.loadDiscoverProfiles(refresh: true);
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Filters',
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear',
              style: GoogleFonts.urbanist(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gender Filter
            _buildSectionTitle('Gender'),
            _buildGenderFilter(),
            const SizedBox(height: 24),
            
            // Age Filter
            _buildSectionTitle('Age Range'),
            _buildAgeFilter(),
            const SizedBox(height: 24),
            
            // Country Filter
            _buildSectionTitle('Country'),
            _buildCountryFilter(),
            const SizedBox(height: 24),
            
            // Profession Filter
            _buildSectionTitle('Profession'),
            _buildProfessionFilter(),
            const SizedBox(height: 24),
            
            // Distance Filter
            _buildSectionTitle('Distance'),
            _buildDistanceFilter(),
            const SizedBox(height: 32),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.urbanist(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildGenderFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: _genders.map((gender) {
          final isSelected = _selectedGender == gender;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = isSelected ? null : gender;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                gender,
                style: GoogleFonts.urbanist(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAgeFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 80,
            divisions: 62,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withValues(alpha: 0.3),
            onChanged: (RangeValues values) {
              setState(() {
                _ageRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_ageRange.start.round()} years',
                style: GoogleFonts.urbanist(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_ageRange.end.round()} years',
                style: GoogleFonts.urbanist(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedCountry,
        decoration: InputDecoration(
          hintText: 'Select Country',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: _countries.map((country) {
          return DropdownMenuItem(
            value: country,
            child: Text(
              country,
              style: GoogleFonts.urbanist(),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCountry = value;
          });
        },
      ),
    );
  }

  Widget _buildProfessionFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedProfession,
        decoration: InputDecoration(
          hintText: 'Select Profession',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: _professions.map((profession) {
          return DropdownMenuItem(
            value: profession,
            child: Text(
              profession,
              style: GoogleFonts.urbanist(),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedProfession = value;
          });
        },
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Slider(
            value: _maxDistance,
            min: 1,
            max: 20000,
            divisions: 100,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withValues(alpha: 0.3),
            onChanged: (value) {
              setState(() {
                _maxDistance = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 mile',
                style: GoogleFonts.urbanist(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_maxDistance.round()} miles',
                style: GoogleFonts.urbanist(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '20,000 miles',
                style: GoogleFonts.urbanist(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 