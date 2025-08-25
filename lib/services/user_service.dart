import '../common/globs.dart';
import '../common/database_helper.dart';

class UserService {
  /// Get current user data
  static Map<String, dynamic>? getCurrentUser() {
    final userData = Globs.udValue(Globs.userPayload);
    if (userData != null && userData is Map<String, dynamic>) {
      return userData;
    }
    return null;
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String mobile,
    required String address,
    String? profilePicture,
  }) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final userId = currentUser['id'];
      
      // Update in local database
      final result = await DatabaseHelper().updateUser(
        id: userId,
        name: name,
        email: email,
        mobile: mobile,
        address: address,
        profilePicture: profilePicture,
      );

      if (result['success'] == true) {
        // Update stored user data
        final updatedUser = {
          ...currentUser,
          'name': name,
          'email': email,
          'mobile': mobile,
          'address': address,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (profilePicture != null) {
          updatedUser['profile_picture'] = profilePicture;
        }

        // Save updated data to preferences
        Globs.udSet(updatedUser, Globs.userPayload);

        return {
          'success': true,
          'message': 'Profile updated successfully',
          'user': updatedUser,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating profile: ${e.toString()}',
      };
    }
  }

  /// Update profile picture only
  static Future<Map<String, dynamic>> updateProfilePicture(String profilePicturePath) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final userId = currentUser['id'];
      
      // Update in local database
      final result = await DatabaseHelper().updateProfilePicture(
        userId: userId,
        profilePicturePath: profilePicturePath,
      );

      if (result['success'] == true) {
        // Update stored user data
        final updatedUser = {
          ...currentUser,
          'profile_picture': profilePicturePath,
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Save updated data to preferences
        Globs.udSet(updatedUser, Globs.userPayload);

        return {
          'success': true,
          'message': 'Profile picture updated successfully',
          'user': updatedUser,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update profile picture',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating profile picture: ${e.toString()}',
      };
    }
  }

  /// Get user's display name
  static String getUserDisplayName() {
    final user = getCurrentUser();
    if (user != null && user['name'] != null) {
      return user['name'];
    }
    return 'User';
  }

  /// Get user's email
  static String getUserEmail() {
    final user = getCurrentUser();
    if (user != null && user['email'] != null) {
      return user['email'];
    }
    return '';
  }

  /// Get user's mobile
  static String getUserMobile() {
    final user = getCurrentUser();
    if (user != null && user['mobile'] != null) {
      return user['mobile'];
    }
    return '';
  }

  /// Get user's address
  static String getUserAddress() {
    final user = getCurrentUser();
    if (user != null && user['address'] != null) {
      return user['address'];
    }
    return '';
  }

  /// Get user's profile picture
  static String? getUserProfilePicture() {
    final user = getCurrentUser();
    if (user != null && user['profile_picture'] != null) {
      return user['profile_picture'];
    }
    return null;
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return Globs.udValueBool(Globs.userLogin);
  }

  /// Logout user
  static Future<void> logout() async {
    Globs.udSet(null, Globs.userPayload);
    Globs.udBoolSet(false, Globs.userLogin);
  }
}