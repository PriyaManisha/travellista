import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:travellista/models/profile.dart';
import 'package:travellista/util/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Profile? _profile;
  Profile? get profile => _profile;

  StreamSubscription<Profile?>? _profileSubscription;

  void listenToProfile(String userID) {
    _profileSubscription?.cancel();

    _profileSubscription = _profileService.streamProfile(userID).listen(
          (profileData) {
        _profile = profileData;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) print("streamProfile error: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveProfile(Profile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _profileService.setProfile(profile);
    } catch (e) {
      if (kDebugMode) {
        print("Error saving profile: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cancel subscription to avoid memory leaks
    _profileSubscription?.cancel();
    super.dispose();
  }
}
