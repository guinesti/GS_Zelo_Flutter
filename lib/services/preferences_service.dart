import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _chaveOnboardingVisto = 'onboarding_visto';

  Future<bool> onboardingFoiVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveOnboardingVisto) ?? false;
  }

  Future<void> salvarOnboardingVisto(bool visto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveOnboardingVisto, visto);
  }
}
