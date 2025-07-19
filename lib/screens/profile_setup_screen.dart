import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _professionController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _workLocationController = TextEditingController();
  
  File? _profileImage;
  int _age = 25;
  String _nursingSpecialty = 'General Nursing';
  final List<String> _selectedInterests = [];
  final Map<String, bool> _preferences = {
    'showAge': true,
    'showLocation': true,
    'showProfession': true,
    'allowMessages': true,
    'allowVideoCall': true,
    'allowPhoneCall': true,
  };

  final List<String> _nursingSpecialties = [
    'General Nursing',
    'ICU/Critical Care',
    'Emergency Room',
    'Pediatrics',
    'Surgery',
    'Obstetrics',
    'Mental Health',
    'Oncology',
    'Geriatrics',
    'Home Health',
    'Travel Nursing',
    'Nurse Practitioner',
    'Other'
  ];

  final List<String> _availableInterests = [
    'Travel',
    'Fitness',
    'Reading',
    'Cooking',
    'Music',
    'Movies',
    'Art',
    'Photography',
    'Dancing',
    'Hiking',
    'Yoga',
    'Meditation',
    'Volunteering',
    'Sports',
    'Gaming',
    'Fashion',
    'Technology',
    'Gardening',
    'Pets',
    'Coffee',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _professionController.dispose();
    _jobTitleController.dispose();
    _workLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('📸 PROFILE_SETUP: Opening image picker');
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print('📸 PROFILE_SETUP: Image selected: ${image.path}');
        setState(() {
          _profileImage = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo selected successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('📸 PROFILE_SETUP: No image selected');
      }
    } catch (e) {
      print('❌ PROFILE_SETUP: Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _complete() async {
    print('📋 PROFILE_SETUP: Attempting to complete profile setup');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ PROFILE_SETUP: Form validation failed');
      return;
    }
    
    // Mandatory image upload validation
    if (_profileImage == null) {
      print('❌ PROFILE_SETUP: Profile image required');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload a profile photo to continue'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Upload',
            onPressed: _pickImage,
          ),
        ),
      );
      return;
    }
    
    print('📋 PROFILE_SETUP: Profile image selected: ${_profileImage?.path}');
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final profileData = {
      'bio': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      'city': _cityController.text.trim(),
      'profession': _professionController.text.trim(),
      'job_title': _jobTitleController.text.trim(),
      'work_location': _workLocationController.text.trim(),
      'age': _age,
      'nursing_specialty': _nursingSpecialty,
      'interests': _selectedInterests,
      'preferences': _preferences,
      'profile_image': _profileImage?.path,
    };
    
    print('📋 PROFILE_SETUP: Sending profile data to backend...');
    final success = await auth.updateProfile(profileData);
    
    if (!mounted) return;
    
    if (success) {
      print('✅ PROFILE_SETUP: Profile setup successful');
      // Navigate to main app (Discovery screen)
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      print('❌ PROFILE_SETUP: Profile setup failed: ${auth.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Profile setup failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Setup Your Profile',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section - REQUIRED
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(
                            color: _profileImage != null ? AppColors.success : AppColors.error,
                            width: 3,
                          ),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'REQUIRED',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _profileImage != null ? 'Profile Photo Added ✓' : 'Add Profile Photo (Required)',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _profileImage != null ? AppColors.success : AppColors.error,
                      ),
                    ),
                    if (_profileImage == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Upload a photo to continue',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Bio Section
              _buildSectionTitle('About You'),
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell us about yourself...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bio';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Age Section
              _buildSectionTitle('Age'),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _age.toDouble(),
                      min: 18,
                      max: 65,
                      divisions: 47,
                      label: _age.toString(),
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => _age = value.round()),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _age.toString(),
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Location Section
              _buildSectionTitle('Location'),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'City, State',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Your city',
              ),
              
              const SizedBox(height: 20),
              
              // Professional Section
              _buildSectionTitle('Professional Information'),
              _buildTextField(
                controller: _professionController,
                label: 'Profession',
                hint: 'e.g., Registered Nurse',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your profession';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _jobTitleController,
                label: 'Job Title',
                hint: 'e.g., ICU Nurse',
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _workLocationController,
                label: 'Work Location',
                hint: 'Hospital/Clinic name',
              ),
              
              const SizedBox(height: 15),
              
              // Nursing Specialty
              _buildSectionTitle('Nursing Specialty'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButton<String>(
                  value: _nursingSpecialty,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _nursingSpecialties.map((String specialty) {
                    return DropdownMenuItem<String>(
                      value: specialty,
                      child: Text(
                        specialty,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _nursingSpecialty = value!),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Interests Section
              _buildSectionTitle('Interests'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Privacy Preferences
              _buildSectionTitle('Privacy Preferences'),
              ..._preferences.entries.map((entry) {
                return _buildPreferenceSwitch(
                  title: _getPreferenceTitle(entry.key),
                  value: entry.value,
                  onChanged: (value) {
                    setState(() {
                      _preferences[entry.key] = value;
                    });
                  },
                );
              }).toList(),
              
              const SizedBox(height: 30),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _complete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Continue',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.urbanist(
        fontSize: 16,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.urbanist(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.urbanist(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: AppColors.text,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _getPreferenceTitle(String key) {
    switch (key) {
      case 'showAge':
        return 'Show Age';
      case 'showLocation':
        return 'Show Location';
      case 'showProfession':
        return 'Show Profession';
      case 'allowMessages':
        return 'Allow Messages';
      case 'allowVideoCall':
        return 'Allow Video Calls';
      case 'allowPhoneCall':
        return 'Allow Phone Calls';
      default:
        return key;
    }
  }
} 
