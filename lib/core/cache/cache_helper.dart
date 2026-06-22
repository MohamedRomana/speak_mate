import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _preferences;

  /// إشعار يتغيّر مع العنوان عشان الواجهات تتحدّث فوراً بعد تحديث الموقع.
  static final ValueNotifier<String> addressNotifier = ValueNotifier<String>('');
  static const _userId = 'id';
  static const _language = 'lang';
  static const _showImage = 'showImage';
  static const _deviceToken = 'deviceToken';
  static const _authToken = 'authToken';
  static const _activeChild = 'activeChildId';
  static const _type = 'type';
  static const _intro = 'intro';
  static const _address = 'address';
  static const _driverStatus = 'driverStatus';
  static const _userName = 'userName';
  static const _rememberMe = 'rememberMe';
  static const _themeMode = 'themeMode';
  static const _difficultyType = 'difficultyType';
  static const _textScale = 'textScale';
  static const _highContrast = 'highContrast2';
  static const _offlineMode = 'offlineMode';
  static const _voiceCommands = 'voiceCommands';
  static const _lat = 'lat';
  static const _lng = 'lng';

  static init() async {
    _preferences = await SharedPreferences.getInstance();
    addressNotifier.value = _preferences.getString(_address) ?? '';
  }

  static String getAddress() {
    return _preferences.getString(_address) ?? '';
  }

  static setAddress(String? address) async {
    await _preferences.setString(_address, address ?? '');
    addressNotifier.value = address ?? '';
  }

  static setLat(String? lat) async {
    await _preferences.setString(_lat, lat ?? '');
  }

  static String getLat() {
    return _preferences.getString(_lat) ?? '';
  }

  static setLng(String? lng) async {
    await _preferences.setString(_lng, lng ?? '');
  }

  static String getLng() {
    return _preferences.getString(_lng) ?? '';
  }

  static setUserId(String? id) async {
    await _preferences.setString(_userId, id ?? '');
  }

  static String getUserId() {
    return _preferences.getString(_userId) ?? '';
  }

  static setShowIntro(bool? showIntro) async {
    await _preferences.setBool(_intro, showIntro ?? false);
  }

  static bool getShowIntro() {
    return _preferences.getBool(_intro) ?? false;
  }

  static setShowImage(bool? showImage) async {
    await _preferences.setBool(_showImage, showImage ?? false);
  }

  static bool getShowImage() {
    return _preferences.getBool(_showImage) ?? false;
  }
  

  static setDeviceToken(String? deviceToken) async {
    await _preferences.setString(_deviceToken, deviceToken ?? '');
  }

  static String getDeviceToken() {
    return _preferences.getString(_deviceToken) ?? '';
  }

  /// رمز المصادقة (Bearer) للـ API الحقيقي.
  static Future<void> setAuthToken(String? token) async {
    await _preferences.setString(_authToken, token ?? '');
  }

  static String getAuthToken() {
    return _preferences.getString(_authToken) ?? '';
  }

  static Future<void> clearAuthToken() async {
    await _preferences.remove(_authToken);
  }

  /// معرّف الطفل النشط حاليًا (للباقة العائلية).
  static Future<void> setActiveChildId(String? id) async {
    await _preferences.setString(_activeChild, id ?? '');
  }

  static String getActiveChildId() {
    return _preferences.getString(_activeChild) ?? '';
  }

  static setUserType(String? type) async {
    await _preferences.setString(_type, type ?? '');
  }

  static String getUserType() {
    return _preferences.getString(_type) ?? '';
  }

  static removeUserId(String key) async {
    await _preferences.remove(_userId);
  }

  static clearData() async {
    await _preferences.clear();
  }

  static setLang(lang) async {
    await _preferences.setString(_language, lang);
  }

  static String getLang() {
    return _preferences.getString(_language) ?? "";
  }

  /// حالة موافقة السائق المخزّنة (pending / approved / rejected / suspended).
  static setDriverStatus(String? status) async {
    await _preferences.setString(_driverStatus, status ?? '');
  }

  static String getDriverStatus() {
    return _preferences.getString(_driverStatus) ?? '';
  }

  static setUserName(String? name) async {
    await _preferences.setString(_userName, name ?? '');
  }

  static String getUserName() {
    return _preferences.getString(_userName) ?? '';
  }

  static setRememberMe(bool value) async {
    await _preferences.setBool(_rememberMe, value);
  }

  static bool getRememberMe() {
    return _preferences.getBool(_rememberMe) ?? false;
  }

  /// وضع الثيم المخزّن: 'light' / 'dark' / 'system' (افتراضي system).
  static setThemeMode(String mode) async {
    await _preferences.setString(_themeMode, mode);
  }

  static String getThemeMode() {
    // VoiceBridge AI افتراضيًا Dark Mode.
    return _preferences.getString(_themeMode) ?? 'dark';
  }

  /// نوع صعوبة المتدرّب — يُستخدم لتخصيص التمارين المناسبة.
  static setDifficultyType(String? value) async {
    await _preferences.setString(_difficultyType, value ?? '');
  }

  static String getDifficultyType() {
    final v = _preferences.getString(_difficultyType) ?? '';
    return v.isEmpty ? 'difficultySpeech' : v;
  }

  /// عامل تكبير النص (1.0 افتراضي).
  static setTextScale(double value) async {
    await _preferences.setDouble(_textScale, value);
  }

  static double getTextScale() {
    return _preferences.getDouble(_textScale) ?? 1.0;
  }

  static setHighContrast(bool value) async {
    await _preferences.setBool(_highContrast, value);
  }

  static bool getHighContrast() {
    return _preferences.getBool(_highContrast) ?? false;
  }

  static setOfflineMode(bool value) async {
    await _preferences.setBool(_offlineMode, value);
  }

  static bool getOfflineMode() {
    return _preferences.getBool(_offlineMode) ?? false;
  }

  static setVoiceCommands(bool value) async {
    await _preferences.setBool(_voiceCommands, value);
  }

  static bool getVoiceCommands() {
    return _preferences.getBool(_voiceCommands) ?? false;
  }
}
