import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../utils/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _professionController = TextEditingController();
  final _ageController = TextEditingController();
  
  User? _user;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('✏️ EDIT_PROFILE: Loading user data...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        // Try to fetch fresh user data first
        try {
          final response = await ApiService.get('/api/auth/me');
          if (response['success'] == true && response['data'] != null) {
            _user = User.fromJson(response['data']);
            print('✅ EDIT_PROFILE: Fresh user data loaded');
          } else {
            _user = currentUser;
            print('⚠️ EDIT_PROFILE: Using cached user data');
          }
        } catch (e) {
          _user = currentUser;
          print('⚠️ EDIT_PROFILE: Backend failed, using cached: $e');
        }
        
        // Populate form fields
        _firstNameController.text = _user?.firstName ?? '';
        _lastNameController.text = _user?.lastName ?? '';
        _bioController.text = _user?.bio ?? '';
        _locationController.text = _user?.location ?? '';
        _professionController.text = _user?.profession ?? '';
        _ageController.text = _user?.age?.toString() ?? '';
        
        setState(() {
          _isLoading = false;
        });
        
        print('✅ EDIT_PROFILE: User data loaded successfully');
      } else {
        throw Exception('No user data available');
      }
    } catch (e) {
      print('❌ EDIT_PROFILE: Error loading user data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('✅ EDIT_PROFILE: Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('❌ EDIT_PROFILE: Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('✏️ EDIT_PROFILE: Saving profile...');
      
      Map<String, dynamic> profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'profession': _professionController.text.trim(),
      };
      
      // Add age if provided
      if (_ageController.text.trim().isNotEmpty) {
        profileData['age'] = int.tryParse(_ageController.text.trim());
      }

      // Upload image first if selected
      String? imageUrl;
      if (_selectedImage != null) {
        print('✏️ EDIT_PROFILE: Uploading new profile image...');
        try {
          final imageResponse = await ApiService.uploadFile(
            '/api/user/upload-photo',
            _selectedImage!,
            fieldName: 'photo',
          );
          
          if (imageResponse['success'] == true && imageResponse['data'] != null) {
            imageUrl = imageResponse['data']['url'] ?? imageResponse['data']['image_url'];
            print('✅ EDIT_PROFILE: Image uploaded: $imageUrl');
            profileData['profile_image_url'] = imageUrl;
          } else {
            print('⚠️ EDIT_PROFILE: Image upload failed, continuing without image');
          }
        } catch (e) {
          print('❌ EDIT_PROFILE: Image upload error: $e');
          // Continue without image update
        }
      }

      // Update profile
      final response = await ApiService.put('/api/user/profile', profileData);
      
      if (response['success'] == true) {
        print('✅ EDIT_PROFILE: Profile updated successfully');
        
        // Update the user object
        if (_user != null) {
          _user = _user!.copyWith(
            firstName: profileData['first_name'],
            lastName: profileData['last_name'],
            bio: profileData['bio'],
            location: profileData['location'],
            profession: profileData['profession'],
            age: profileData['age'],
            profileImageUrl: imageUrl ?? _user!.profileImageUrl,
          );
        }
        
        // Update auth provider with new user data
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (response['data'] != null) {
          final updatedUser = User.fromJson(response['data']);
          authProvider.updateCurrentUser(updatedUser);
        } else if (_user != null) {
          authProvider.updateCurrentUser(_user!);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to previous screen
        Navigator.pop(context, true); // Return true to indicate success
        
      } else {
        throw Exception(response['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('❌ EDIT_PROFILE: Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.urbanist(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
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
              'Error Loading Profile',
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
              onPressed: _loadUserData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Image Section
            _buildImageSection(),
            const SizedBox(height: 32),
            
            // Form Fields
            _buildFormFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : (_user?.profileImageUrl != null && _user!.profileImageUrl!.isNotEmpty)
                      ? Image.network(
                          _user!.profileImageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt),
          label: Text(
            'Change Photo',
            style: GoogleFonts.urbanist(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 50,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        _buildTextField(
          controller: _ageController,
          label: 'Age',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.trim().isNotEmpty == true) {
              final age = int.tryParse(value!);
              if (age == null || age < 18 || age > 100) {
                return 'Please enter a valid age (18-100)';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        _buildTextField(
          controller: _professionController,
          label: 'Profession',
          validator: (value) {
            if (value?.trim().isEmpty == true) {
              return 'Profession is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        _buildTextField(
          controller: _locationController,
          label: 'Location',
        ),
        const SizedBox(height: 20),
        
        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.urbanist(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.urbanist(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
      ),
    );
  }
} 
