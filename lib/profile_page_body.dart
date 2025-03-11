import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _isEditing = false;
  bool _localIsSaving = false;
  String? _firstName;
  String? _lastName;
  String _displayName = "";
  String _email = "";
  String? _photoUrl;
  String? _pendingRemovalUrl;

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageOverride ?? StorageService();
    // using "demoUser" for now:
    context.read<ProfileProvider>().listenToProfile("demoUser");
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

    if (!_isEditing && _firstName == null) {
      _firstName = currentProfile.firstName;
      _lastName = currentProfile.lastName;
      _photoUrl = currentProfile.photoUrl;
      _displayName = currentProfile.displayName;
      _email = currentProfile.email;
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          _buildMainContent(profileProvider),
          if (_localIsSaving || (isLoadingProfile /*&& currentProfile != null*/))
            _buildOverlaySpinner(),
        ],
      ),
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
          const SizedBox(height: 16),
          _buildActionButtons(provider),
          const SizedBox(height: 24),
        ] else ...[
          _buildDisplayRow("First Name", _firstName ?? ''),
          const SizedBox(height: 16),
          _buildDisplayRow("Last Name", _lastName ?? ''),
          const SizedBox(height: 16),
          _buildDisplayRow("Display Name", _displayName),
          const SizedBox(height: 16),
          _buildDisplayRow("Email", _email),
          const SizedBox(height: 16),
          _buildActionButtons(provider),
          const SizedBox(height: 24),
        ],
        _buildDarkModeSwitch(),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                  ? NetworkImage("$_photoUrl&t=${DateTime.now().millisecondsSinceEpoch}")
                  : null,
              child: (_photoUrl == null || _photoUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            if (_isEditing && _photoUrl != null && _photoUrl!.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  onPressed: () async {
                    setState(() {
                      _pendingRemovalUrl = _photoUrl;
                      _photoUrl = null;
                    });
                  },
                ),
              ),
          ],
        ),
        if (_isEditing)
          InkWell(
            onTap: _pickProfilePicture,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Change Picture",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context).textTheme;
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.bodyLarge,
        hintStyle: theme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
      ),
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    final theme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          "$label: ",
          style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value, style: theme.bodyLarge)),
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
              setState(() {
                _isEditing = false;
                _photoUrl = context.read<ProfileProvider>().profile?.photoUrl;
                _pendingRemovalUrl = null;
              });
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    } else {
      return TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 0),
        ),
        onPressed: () => setState(() => _isEditing = true),
        child: Text(
          "Edit Profile",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          ),
        ),
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
              onPressed: () => ctx.pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => ctx.pop(true),
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
    if (_pendingRemovalUrl != null) {
      try {
        await _storageService.deleteFileByUrl(_pendingRemovalUrl!);
      } catch (e) {
        debugPrint("Storage deletion error: $e");
      }
    }
    final updatedProfile = oldProfile.copyWith(
      firstName: _firstName,
      lastName: _lastName,
      displayName: _displayName,
      email: _email,
      photoUrl: _photoUrl,
    );
    try {
      await provider.saveProfile(updatedProfile);
      _pendingRemovalUrl = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
      setState(() => _isEditing = false);
    } catch (e) {
      debugPrint("Error saving profile: $e");
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
      child: Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    final theme = Theme.of(context).textTheme;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return SwitchListTile(
          contentPadding: const EdgeInsets.only(left: 0, right: 16.0),
          title: Text(
            'Dark Mode',
            style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          value: currentTheme == ThemeMode.dark,
          onChanged: (_) => ThemeManager.toggleTheme(),
        );
      },
    );
  }
}
