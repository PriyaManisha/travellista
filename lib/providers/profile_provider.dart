import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travellista/models/profile.dart';
import 'package:travellista/util/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Profile? _profile;
  Profile? get profile => _profile;

  Future<void> fetchProfile(String userID) async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await _profileService.getProfile(userID);
      _profile = fetched;
    } catch (e) {
      // handle error or rethrow
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(Profile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _profileService.setProfile(profile);
      _profile = profile;
    } catch (e) {
      if (kDebugMode) {
        print("Error saving profile: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
