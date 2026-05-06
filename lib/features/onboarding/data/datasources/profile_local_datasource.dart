import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getProfile();
  Future<void> saveProfile(UserProfileModel model);
  Future<bool> isOnboardingComplete();
  Future<void> deleteProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  Box<UserProfileModel> get _box =>
      Hive.box<UserProfileModel>(HiveBoxNames.userProfile);

  @override
  Future<UserProfileModel?> getProfile() async {
    try {
      final data = _box.get('profile');
      if (data == null) return null;
      return data;
    } catch (e) {
      throw CacheException(message: 'Erreur lecture profil : $e');
    }
  }

  @override
  Future<void> saveProfile(UserProfileModel model) async {
    try {
      await _box.put('profile', model);
    } catch (e) {
      throw CacheException(message: 'Erreur sauvegarde profil : $e');
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      final profile = await getProfile();
      return profile?.onboardingComplete ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      await _box.delete('profile');
    } catch (e) {
      throw CacheException(message: 'Erreur suppression profil : $e');
    }
  }
}
