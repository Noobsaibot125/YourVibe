import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageService _storage = StorageService();

  String _name = "User";
  String _bio = "No bio yet.";

  String get name => _name;
  String get bio => _bio;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _storage.init();
    _name = _storage.getProfileName();
    _bio = _storage.getProfileBio();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(String newName, String newBio) async {
    _name = newName;
    _bio = newBio;
    await _storage.saveProfile(newName, newBio);
    notifyListeners();
  }
}
