import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _professionController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedGender;
  List<String> _profileImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _locationController.text = user.location ?? '';
      _professionController.text = user.profession ?? '';
      _specialtyController.text = user.nursingSpecialty ?? '';
      _workLocationController.text = user.workLocation ?? '';
      _jobTitleController.text = user.jobTitle ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _selectedGender = user.gender;
      _profileImages = user.profileImages ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    _specialtyController.dispose();
    _workLocationController.dispose();
    _jobTitleController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateProfile({
      'name': _nameController.text,
      'bio': _bioController.text,
      'location': _locationController.text,
      'profession': _professionController.text,
      'nursing_specialty': _specialtyController.text,
      'work_location': _workLocationController.text,
      'job_title': _jobTitleController.text,
      'age': int.tryParse(_ageController.text),
      'phone_number': _phoneController.text,
      'gender': _selectedGender,
      'profile_images': _profileImages,
    });

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to update profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: Text(
              'Save',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photos Section
              _buildSectionTitle('Profile Photos'),
              _buildPhotoGrid(),
              const SizedBox(height: 24),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 100) {
                    return 'Please enter a valid age (18-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Professional Information
              _buildSectionTitle('Professional Information'),
              _buildTextField(
                controller: _jobTitleController,
                label: 'Job Title',
                icon: Icons.work,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _specialtyController,
                label: 'Nursing Specialty',
                icon: Icons.medical_services,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _workLocationController,
                label: 'Work Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              _buildTextField(
                controller: _locationController,
                label: 'City, State',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bio';
                  }
                  if (value.length < 20) {
                    return 'Bio must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      style: GoogleFonts.urbanist(
        fontSize: 16,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wc, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Gender',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Male'),
                  value: 'male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add up to 6 photos',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildPhotoSlot(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final hasImage = index < _profileImages.length;
    
    return GestureDetector(
      onTap: () => _showPhotoOptions(index),
      child: Container(
        decoration: BoxDecoration(
          color: hasImage ? Colors.transparent : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasImage ? Colors.transparent : AppColors.border,
            style: hasImage ? BorderStyle.none : BorderStyle.solid,
          ),
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _profileImages[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.border,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add Photo',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Photo',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _addPhotoFromCamera(index);
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _addPhotoFromGallery(index);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPhotoFromCamera(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          if (index < _profileImages.length) {
            _profileImages[index] = image.path;
          } else {
            _profileImages.add(image.path);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _addPhotoFromGallery(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          if (index < _profileImages.length) {
            _profileImages[index] = image.path;
          } else {
            _profileImages.add(image.path);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _profileImages.removeAt(index);
    });
  }
} 
