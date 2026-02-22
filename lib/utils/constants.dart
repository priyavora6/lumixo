class AppConstants {
  // App Info
  static const String appName = 'Lumixo';
  static const String appTagline = 'Transform With Love & Light';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String colCategories = 'categories';
  static const String colStyles = 'styles';
  static const String colPrompts = 'prompts';
  static const String colUsers = 'users';
  static const String colEdits = 'edits';
  static const String colSavedPrompts = 'saved_prompts';
  static const String colAppConfig = 'app_config';
  static const String docSettings = 'settings';

  // Firestore Fields
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldCoins = 'coins';
  static const String fieldIsPremium = 'is_premium';
  static const String fieldFreeEditsToday = 'free_edits_today';
  static const String fieldLastEditDate = 'last_edit_date';
  static const String fieldTotalEdits = 'total_edits';
  static const String fieldCreatedAt = 'created_at';
  static const String fieldExpiresAt = 'expires_at';
  static const String fieldIsTrending = 'is_trending';
  static const String fieldOrder = 'order';
  static const String fieldIsActive = 'is_active';
  static const String fieldPrompt = 'prompt';
  static const String fieldIsPremiumStyle = 'is_premium';
  static const String fieldReplicateKey = 'replicate_api_key';

  // SharedPreferences Keys
  static const String prefOnboardingSeen = 'onboarding_seen';
  static const String prefUserId = 'user_id';

  // Default Values
  static const int defaultFreeEdits = 3;
  static const int defaultCoins = 10;
  static const int freeHistoryDays = 30;
  static const int freeMaxEdits = 50;

  // Replicate API
  static const String replicateBaseUrl =
      'https://api.replicate.com/v1/predictions';
  static const String replicateModel =
      'stability-ai/stable-diffusion-img2img:15a3689ee13b0d2616e98820eca31d4af4b8dfd4';

  // Storage Paths
  static const String storageUploads = 'uploads';
  static const String storageResults = 'results';
}