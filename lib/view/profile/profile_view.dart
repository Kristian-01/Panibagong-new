import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/color_extension.dart';
import '../../common/extension.dart';
import '../../common/globs.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../services/user_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  
  bool isEditing = false;
  bool isLoading = false;
  String? profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserService.getCurrentUser();
    if (user != null) {
      txtName.text = user['name'] ?? '';
      txtEmail.text = user['email'] ?? '';
      txtMobile.text = user['mobile'] ?? '';
      txtAddress.text = user['address'] ?? '';
      profileImagePath = user['profile_picture'];
    }
  }

  Future<void> _pickImage() async {
    try {
      // Show options for camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Select Profile Picture",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.photo_library,
                          label: "Gallery",
                          onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.photo_camera,
                          label: "Camera",
                          onTap: () => Navigator.of(context).pop(ImageSource.camera),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            profileImagePath = image.path;
          });

          // Update profile picture in database
          final result = await UserService.updateProfilePicture(image.path);
          if (result['success'] == true) {
            _showSuccessMessage("Profile picture updated successfully!");
          } else {
            _showErrorMessage(result['message'] ?? "Failed to update profile picture");
          }
        }
      }
    } catch (e) {
      _showErrorMessage("Error picking image: ${e.toString()}");
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: TColor.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: TColor.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TColor.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: TColor.primary,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            image: profileImagePath != null && File(profileImagePath!).existsSync()
                ? DecorationImage(
                    image: FileImage(File(profileImagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: profileImagePath == null || !File(profileImagePath!).existsSync()
              ? Text(
                  UserService.getUserDisplayName().isNotEmpty 
                      ? UserService.getUserDisplayName()[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TColor.primary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColor.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: TColor.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required bool enabled,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RoundTextfield(
          hintText: hintText,
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          left: icon != null
              ? Container(
                  alignment: Alignment.center,
                  width: 30,
                  child: Icon(
                    icon,
                    color: enabled ? TColor.primary : TColor.placeholder,
                    size: 20,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: TColor.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem("Orders", "12", Icons.shopping_bag),
          ),
          Container(
            width: 1,
            height: 40,
            color: TColor.primary.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem("Saved", "₱2,450", Icons.savings),
          ),
          Container(
            width: 1,
            height: 40,
            color: TColor.primary.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem("Points", "340", Icons.star),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: TColor.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 10,
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),
                
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: TColor.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "My Profile",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!isEditing)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        icon: Icon(Icons.edit, color: TColor.primary, size: 18),
                        label: Text(
                          "Edit",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Profile Picture
                _buildProfileImage(),
                
                const SizedBox(height: 15),
                
                // User Info
                Text(
                  UserService.getUserDisplayName(),
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  UserService.getUserEmail(),
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Profile Stats
                _buildProfileStats(),
                
                const SizedBox(height: 20),
                
                // Profile Form
                Column(
                  children: [
                    // Name Field
                    _buildFormField(
                      label: "Full Name",
                      controller: txtName,
                      hintText: "Enter your full name",
                      enabled: isEditing,
                      icon: Icons.person,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email Field
                    _buildFormField(
                      label: "Email Address",
                      controller: txtEmail,
                      hintText: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      enabled: isEditing,
                      icon: Icons.email,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Mobile Field
                    _buildFormField(
                      label: "Mobile Number",
                      controller: txtMobile,
                      hintText: "Enter your mobile number",
                      keyboardType: TextInputType.phone,
                      enabled: isEditing,
                      icon: Icons.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address Field
                    _buildFormField(
                      label: "Address",
                      controller: txtAddress,
                      hintText: "Enter your address",
                      enabled: isEditing,
                      icon: Icons.location_on,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    if (isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: RoundButton(
                              title: "Cancel",
                              onPressed: () {
                                _loadUserData(); // Reset data
                                setState(() {
                                  isEditing = false;
                                });
                              },
                              type: RoundButtonType.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: RoundButton(
                              title: isLoading ? "Saving..." : "Save Changes",
                              onPressed: isLoading ? null : _saveProfile,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Additional Profile Options
                      _buildProfileOption(
                        icon: Icons.security,
                        title: "Change Password",
                        subtitle: "Update your password",
                        onTap: () {
                          _showInfoMessage("Change password feature coming soon!");
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildProfileOption(
                        icon: Icons.notifications,
                        title: "Notifications",
                        subtitle: "Manage notification preferences",
                        onTap: () {
                          _showInfoMessage("Notification settings coming soon!");
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildProfileOption(
                        icon: Icons.help,
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        onTap: () {
                          _showInfoMessage("Help & Support coming soon!");
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Sign out of your account",
                        onTap: _showLogoutDialog,
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive 
                ? Colors.red.withOpacity(0.2) 
                : TColor.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.1) 
                    : TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : TColor.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : TColor.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TColor.secondaryText,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (txtName.text.trim().isEmpty) {
      _showErrorMessage("Please enter your name");
      return;
    }

    if (!txtEmail.text.isEmail) {
      _showErrorMessage("Please enter a valid email");
      return;
    }

    if (txtMobile.text.trim().isEmpty) {
      _showErrorMessage("Please enter your mobile number");
      return;
    }

    if (txtAddress.text.trim().isEmpty) {
      _showErrorMessage("Please enter your address");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await UserService.updateProfile(
        name: txtName.text.trim(),
        email: txtEmail.text.trim(),
        mobile: txtMobile.text.trim(),
        address: txtAddress.text.trim(),
        profilePicture: profileImagePath,
      );

      setState(() {
        isLoading = false;
      });

      if (result['success'] == true) {
        setState(() {
          isEditing = false;
        });
        
        _showSuccessMessage("Profile updated successfully!");
      } else {
        _showErrorMessage(result['message'] ?? "Failed to update profile");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorMessage("Error updating profile: ${e.toString()}");
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: TColor.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: TColor.secondaryText)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await UserService.logout();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    txtName.dispose();
    txtEmail.dispose();
    txtMobile.dispose();
    txtAddress.dispose();
    super.dispose();
  }
}