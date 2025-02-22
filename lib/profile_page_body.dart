import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travellista/models/profile.dart';
import 'package:travellista/util/profile_service.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/util/theme_manager.dart';

class ProfilePageBody extends StatefulWidget {
  const ProfilePageBody({super.key});

  @override
  State<ProfilePageBody> createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<ProfilePageBody> {
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  // Hard-coded for now
  String _userID = "demoUser";

  // Booleans for loading states
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // Profile fields
  String? _firstName;
  String? _lastName;
  String _displayName = "";
  String _email = "";
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getProfile(_userID);
      if (profile != null) {
        setState(() {
          _firstName = profile.firstName;
          _lastName = profile.lastName;
          _displayName = profile.displayName;
          _email = profile.email;
          _photoUrl = profile.photoUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Image picker uses StorageService
  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // user canceled

    try {
      // Show spinner while uploading image
      setState(() => _isSaving = true);

      final extension = pickedFile.path.split('.').last;
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final downloadUrl = await _storageService.uploadFile(
        File(pickedFile.path),
        'profile_pics/$fileName',
      );

      setState(() {
        _photoUrl = downloadUrl;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Show confirmation prompt before trying to update + save
  Future<void> _confirmAndSaveProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Profile"),
        content: const Text("Are you sure you want to update your profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _saveProfile();
    }
  }

  // Use spinner while waiting for profile to save
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      // Build new Profile from fields
      final newProfile = Profile(
        userID: _userID,
        firstName: _firstName,
        lastName: _lastName,
        displayName: _displayName,
        email: _email,
        photoUrl: _photoUrl,
      );

      // Save new profile
      await _profileService.setProfile(newProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }

      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _buildMainContent(),
        if (_isSaving)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent() {
    // Add fields for firstName, lastName, displayName, email
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profile Picture
        _buildProfilePicture(),
        const SizedBox(height: 24),

        // If editing, build text fields
        if (_isEditing) ...[
          _buildTextField(
            label: "First Name",
            initialValue: _firstName ?? '',
            onChanged: (val) => _firstName = val,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Last Name",
            initialValue: _lastName ?? '',
            onChanged: (val) => _lastName = val,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Display Name",
            initialValue: _displayName,
            onChanged: (val) => _displayName = val,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Email",
            initialValue: _email,
            onChanged: (val) => _email = val,
          ),
          const SizedBox(height: 24),
        ] else ...[
          _buildDisplayRow("First Name", _firstName ?? ''),
          const SizedBox(height: 16),
          _buildDisplayRow("Last Name", _lastName ?? ''),
          const SizedBox(height: 16),
          _buildDisplayRow("Display Name", _displayName),
          const SizedBox(height: 16),
          _buildDisplayRow("Email", _email),
          const SizedBox(height: 24),
        ],

        // Action Buttons (Edit/Save/Cancel)
        _buildActionButtons(),

        // Theme Toggle
        const SizedBox(height: 24),
        _buildDarkModeSwitch(),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return InkWell(
      onTap: _pickProfilePicture,
      child: CircleAvatar(
        radius: 40,
        backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
            ? NetworkImage(_photoUrl!)
            : null,
        child: (_photoUrl == null || _photoUrl!.isEmpty)
            ? const Icon(Icons.person, size: 40)
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _confirmAndSaveProfile, // shows prompt, then saves
            child: const Text("Save"),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => setState(() => _isEditing = false),
            child: const Text("Cancel"),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: () => setState(() => _isEditing = true),
        child: const Text("Edit Profile"),
      );
    }
  }

  Widget _buildDarkModeSwitch() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return SwitchListTile(
          title: const Text('Dark Mode'),
          value: currentTheme == ThemeMode.dark,
          onChanged: (_) => ThemeManager.toggleTheme(),
        );
      },
    );
  }
}
