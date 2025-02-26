import 'package:flutter/foundation.dart';
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
    //notifying listeners is unnecessary since fetchProfile is only called on initState
    //the rebuild is therefore already in progress
    //hopefully the emulator wont throw any more errors regarding this
    //notifyListeners();
    try {
      final fetched = await _profileService.getProfile(userID);
      _profile = fetched;
    } catch (e) {
      // handle error or rethrow
    } finally {
      _isLoading = false;
      //this one is fine since a single update is necessary to clear the loading screen
      //the intended functionality could be replicated with a FutureBuilder though
      //unless there's an inopportune use case arching over this call
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
