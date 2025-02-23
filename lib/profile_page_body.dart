import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/util/theme_manager.dart';
import 'package:travellista/providers/profile_provider.dart';

class ProfilePageBody extends StatefulWidget {
  final StorageService? storageOverride;
  const ProfilePageBody({super.key, this.storageOverride});

  @override
  State<ProfilePageBody> createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<ProfilePageBody> {
  late StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  // Booleans for loading states
  bool _isEditing = false;
  bool _localIsSaving = false;

  // Profile fields
  String? _firstName;
  String? _lastName;
  String _displayName = "";
  String _email = "";
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageOverride ?? StorageService();
    // st using "demoUser" for now:
    context.read<ProfileProvider>().fetchProfile("demoUser");
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final isLoadingProfile = profileProvider.isLoading;
    final currentProfile = profileProvider.profile;

    if (isLoadingProfile && currentProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentProfile == null) {
      return const Center(child: Text('No profile found'));
    }

    if (!_isEditing) {
      _firstName = currentProfile?.firstName;
      _lastName = currentProfile?.lastName;
      _photoUrl = currentProfile?.photoUrl;
      _displayName = currentProfile!.displayName;
      _email = currentProfile.email;
    }

    return Stack(
      children: [
        _buildMainContent(profileProvider),
        if (_localIsSaving || (isLoadingProfile && currentProfile != null))
          _buildOverlaySpinner(),
      ],
    );
  }

  Widget _buildMainContent(ProfileProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfilePicture(),
        const SizedBox(height: 24),

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

        _buildActionButtons(provider),

        const SizedBox(height: 24),
        _buildDarkModeSwitch(),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return InkWell(
      onTap: _isEditing ? _pickProfilePicture : null,
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

  Widget _buildActionButtons(ProfileProvider provider) {
    if (_isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _confirmAndSaveProfile(provider),
            child: const Text("Save"),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            key: const Key('dialogCancelButton'),
            onPressed: () {
              setState(() => _isEditing = false);
            },
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

  VoidCallback _confirmAndSaveProfile(ProfileProvider provider) {
    return () async {
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
        _saveProfile(provider);
      }
    };
  }

  Future<void> _saveProfile(ProfileProvider provider) async {
    final oldProfile = provider.profile;
    if (oldProfile == null) return;

    // Build new profile
    final updated = oldProfile.copyWith(
      firstName: _firstName,
      lastName: _lastName,
      displayName: _displayName,
      email: _email,
      photoUrl: _photoUrl,
    );

    try {
      await provider.saveProfile(updated);
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
    }
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      setState(() => _localIsSaving = true);

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
      setState(() => _localIsSaving = false);
    }
  }

  Widget _buildOverlaySpinner() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),
    );
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
