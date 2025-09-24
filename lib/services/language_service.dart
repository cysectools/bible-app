import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language service for managing app localization
class LanguageService {
  static const String _languageKey = 'selected_language';
  static LanguageService? _instance;
  
  // Available languages with flags and locale codes
  static const Map<String, LanguageInfo> supportedLanguages = {
    'en': LanguageInfo(
      name: 'English',
      flag: '🇺🇸',
      locale: Locale('en', 'US'),
      nativeName: 'English',
    ),
    'es': LanguageInfo(
      name: 'Spanish',
      flag: '🇪🇸',
      locale: Locale('es', 'ES'),
      nativeName: 'Español',
    ),
    'fr': LanguageInfo(
      name: 'French',
      flag: '🇫🇷',
      locale: Locale('fr', 'FR'),
      nativeName: 'Français',
    ),
    'it': LanguageInfo(
      name: 'Italian',
      flag: '🇮🇹',
      locale: Locale('it', 'IT'),
      nativeName: 'Italiano',
    ),
  };

  static LanguageService get instance {
    _instance ??= LanguageService._();
    return _instance!;
  }

  LanguageService._();

  String _currentLanguageCode = 'en';
  Locale _currentLocale = const Locale('en', 'US');

  /// Get current language code
  String get currentLanguageCode => _currentLanguageCode;

  /// Get current locale
  Locale get currentLocale => _currentLocale;

  /// Get current language info
  LanguageInfo get currentLanguageInfo => supportedLanguages[_currentLanguageCode]!;

  /// Initialize language service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null && supportedLanguages.containsKey(savedLanguage)) {
        await setLanguage(savedLanguage);
      } else {
        // Use device locale if available, otherwise default to English
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final deviceLanguageCode = deviceLocale.languageCode;
        
        if (supportedLanguages.containsKey(deviceLanguageCode)) {
          await setLanguage(deviceLanguageCode);
        } else {
          await setLanguage('en');
        }
      }
    } catch (e) {
      debugPrint('Error initializing language service: $e');
      await setLanguage('en');
    }
  }

  /// Set language and persist it
  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      debugPrint('Unsupported language code: $languageCode');
      return;
    }

    _currentLanguageCode = languageCode;
    _currentLocale = supportedLanguages[languageCode]!.locale;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      debugPrint('Language set to: ${supportedLanguages[languageCode]!.name}');
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  /// Get all supported languages
  List<LanguageInfo> get allLanguages => supportedLanguages.values.toList();

  /// Check if a language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }

  /// Get language info by code
  LanguageInfo? getLanguageInfo(String languageCode) {
    return supportedLanguages[languageCode];
  }
}

/// Language information class
class LanguageInfo {
  final String name;
  final String flag;
  final Locale locale;
  final String nativeName;

  const LanguageInfo({
    required this.name,
    required this.flag,
    required this.locale,
    required this.nativeName,
  });

  @override
  String toString() => '$flag $nativeName';
}

/// Translation keys for the app
class AppTranslations {
  // Navigation & General
  static const String appTitle = 'app_title';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String back = 'back';
  static const String next = 'next';
  static const String previous = 'previous';
  static const String done = 'done';
  static const String cancel = 'cancel';
  static const String save = 'save';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String share = 'share';
  static const String refresh = 'refresh';
  static const String loading = 'loading';
  static const String error = 'error';
  static const String success = 'success';
  static const String retry = 'retry';

  // Home Screen
  static const String welcome = 'welcome';
  static const String dailyVerse = 'daily_verse';
  static const String armorOfGod = 'armor_of_god';
  static const String auditoryPractice = 'auditory_practice';
  static const String verses = 'verses';
  static const String language = 'language';

  // Armor of God
  static const String helmetOfSalvation = 'helmet_of_salvation';
  static const String breastplateOfRighteousness = 'breastplate_of_righteousness';
  static const String beltOfTruth = 'belt_of_truth';
  static const String shoesOfPeace = 'shoes_of_peace';
  static const String shieldOfFaith = 'shield_of_faith';
  static const String swordOfSpirit = 'sword_of_spirit';
  static const String armorPractice = 'armor_practice';
  static const String armorAdvice = 'armor_advice';

  // Practice Screens
  static const String practice = 'practice';
  static const String writing = 'writing';
  static const String dragAndDrop = 'drag_and_drop';
  static const String audio = 'audio';
  static const String checkAnswer = 'check_answer';
  static const String correct = 'correct';
  static const String incorrect = 'incorrect';
  static const String tryAgain = 'try_again';
  static const String excellent = 'excellent';
  static const String goodJob = 'good_job';

  // Profile
  static const String createProfile = 'create_profile';
  static const String editProfile = 'edit_profile';
  static const String name = 'name';
  static const String age = 'age';
  static const String favoriteVerse = 'favorite_verse';
  static const String profileCreated = 'profile_created';
  static const String profileUpdated = 'profile_updated';

  // Settings
  static const String notifications = 'notifications';
  static const String theme = 'theme';
  static const String privacy = 'privacy';
  static const String about = 'about';
  static const String version = 'version';

  // Permissions
  static const String cameraPermission = 'camera_permission';
  static const String photoPermission = 'photo_permission';
  static const String permissionRequired = 'permission_required';
  static const String permissionDenied = 'permission_denied';
  static const String openSettings = 'open_settings';

  // Bible Verses
  static const String verseOfTheDay = 'verse_of_the_day';
  static const String randomVerse = 'random_verse';
  static const String addToFavorites = 'add_to_favorites';
  static const String shareVerse = 'share_verse';
  static const String saveImage = 'save_image';
  static const String verseSaved = 'verse_saved';

  // Badges
  static const String badges = 'badges';
  static const String noBadgesAvailable = 'no_badges_available';

  // Authentication
  static const String loginSubtitle = 'login_subtitle';
  static const String signingIn = 'signing_in';
  static const String signInWithGoogle = 'sign_in_with_google';
  static const String loginTerms = 'login_terms';
  static const String signInFailed = 'sign_in_failed';
  static const String signInError = 'sign_in_error';

  // Navigation
  static const String more = 'more';
  static const String verses = 'verses';
  static const String memorization = 'memorization';
  static const String armor = 'armor';
  static const String notes = 'notes';
  static const String groups = 'groups';

  // Errors
  static const String networkError = 'network_error';
  static const String apiError = 'api_error';
  static const String unknownError = 'unknown_error';
  static const String noInternetConnection = 'no_internet_connection';
}

/// Translation helper class
class Translations {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Navigation & General
      AppTranslations.appTitle: 'Bible App',
      AppTranslations.home: 'Home',
      AppTranslations.profile: 'Profile',
      AppTranslations.settings: 'Settings',
      AppTranslations.back: 'Back',
      AppTranslations.next: 'Next',
      AppTranslations.previous: 'Previous',
      AppTranslations.done: 'Done',
      AppTranslations.cancel: 'Cancel',
      AppTranslations.save: 'Save',
      AppTranslations.delete: 'Delete',
      AppTranslations.edit: 'Edit',
      AppTranslations.share: 'Share',
      AppTranslations.refresh: 'Refresh',
      AppTranslations.loading: 'Loading...',
      AppTranslations.error: 'Error',
      AppTranslations.success: 'Success',
      AppTranslations.retry: 'Retry',

      // Home Screen
      AppTranslations.welcome: 'Welcome',
      AppTranslations.dailyVerse: 'Daily Verse',
      AppTranslations.armorOfGod: 'Armor of God',
      AppTranslations.auditoryPractice: 'Auditory Practice',
      AppTranslations.verses: 'Verses',
      AppTranslations.language: 'Language',

      // Armor of God
      AppTranslations.helmetOfSalvation: 'Helmet of Salvation',
      AppTranslations.breastplateOfRighteousness: 'Breastplate of Righteousness',
      AppTranslations.beltOfTruth: 'Belt of Truth',
      AppTranslations.shoesOfPeace: 'Shoes of Peace',
      AppTranslations.shieldOfFaith: 'Shield of Faith',
      AppTranslations.swordOfSpirit: 'Sword of the Spirit',
      AppTranslations.armorPractice: 'Armor Practice',
      AppTranslations.armorAdvice: 'Armor Advice',

      // Practice Screens
      AppTranslations.practice: 'Practice',
      AppTranslations.writing: 'Writing',
      AppTranslations.dragAndDrop: 'Drag & Drop',
      AppTranslations.audio: 'Audio',
      AppTranslations.checkAnswer: 'Check Answer',
      AppTranslations.correct: 'Correct!',
      AppTranslations.incorrect: 'Incorrect',
      AppTranslations.tryAgain: 'Try Again',
      AppTranslations.excellent: 'Excellent!',
      AppTranslations.goodJob: 'Good Job!',

      // Profile
      AppTranslations.createProfile: 'Create Profile',
      AppTranslations.editProfile: 'Edit Profile',
      AppTranslations.name: 'Name',
      AppTranslations.age: 'Age',
      AppTranslations.favoriteVerse: 'Favorite Verse',
      AppTranslations.profileCreated: 'Profile Created',
      AppTranslations.profileUpdated: 'Profile Updated',

      // Settings
      AppTranslations.notifications: 'Notifications',
      AppTranslations.theme: 'Theme',
      AppTranslations.privacy: 'Privacy',
      AppTranslations.about: 'About',
      AppTranslations.version: 'Version',

      // Permissions
      AppTranslations.cameraPermission: 'Camera Permission',
      AppTranslations.photoPermission: 'Photo Permission',
      AppTranslations.permissionRequired: 'Permission Required',
      AppTranslations.permissionDenied: 'Permission Denied',
      AppTranslations.openSettings: 'Open Settings',

      // Bible Verses
      AppTranslations.verseOfTheDay: 'Verse of the Day',
      AppTranslations.randomVerse: 'Random Verse',
      AppTranslations.addToFavorites: 'Add to Favorites',
      AppTranslations.shareVerse: 'Share Verse',
      AppTranslations.saveImage: 'Save Image',
      AppTranslations.verseSaved: 'Verse Saved',

      // Badges
      AppTranslations.badges: 'Badges',
      AppTranslations.noBadgesAvailable: 'No badges available',

      // Authentication
      AppTranslations.loginSubtitle: 'Sign in to continue your Bible journey',
      AppTranslations.signingIn: 'Signing in...',
      AppTranslations.signInWithGoogle: 'Sign in with Google',
      AppTranslations.loginTerms: 'By signing in, you agree to our Terms of Service and Privacy Policy',
      AppTranslations.signInFailed: 'Sign in failed. Please try again.',
      AppTranslations.signInError: 'Sign in error',

      // Navigation
      AppTranslations.more: 'More',
      AppTranslations.verses: 'Verses',
      AppTranslations.memorization: 'Memorization',
      AppTranslations.armor: 'Armor',
      AppTranslations.notes: 'Notes',
      AppTranslations.groups: 'Groups',

      // Errors
      AppTranslations.networkError: 'Network Error',
      AppTranslations.apiError: 'API Error',
      AppTranslations.unknownError: 'Unknown Error',
      AppTranslations.noInternetConnection: 'No Internet Connection',
    },
    'es': {
      // Navigation & General
      AppTranslations.appTitle: 'App de la Biblia',
      AppTranslations.home: 'Inicio',
      AppTranslations.profile: 'Perfil',
      AppTranslations.settings: 'Configuración',
      AppTranslations.back: 'Atrás',
      AppTranslations.next: 'Siguiente',
      AppTranslations.previous: 'Anterior',
      AppTranslations.done: 'Hecho',
      AppTranslations.cancel: 'Cancelar',
      AppTranslations.save: 'Guardar',
      AppTranslations.delete: 'Eliminar',
      AppTranslations.edit: 'Editar',
      AppTranslations.share: 'Compartir',
      AppTranslations.refresh: 'Actualizar',
      AppTranslations.loading: 'Cargando...',
      AppTranslations.error: 'Error',
      AppTranslations.success: 'Éxito',
      AppTranslations.retry: 'Reintentar',

      // Home Screen
      AppTranslations.welcome: 'Bienvenido',
      AppTranslations.dailyVerse: 'Versículo del Día',
      AppTranslations.armorOfGod: 'Armadura de Dios',
      AppTranslations.auditoryPractice: 'Práctica Auditiva',
      AppTranslations.verses: 'Versículos',
      AppTranslations.language: 'Idioma',

      // Armor of God
      AppTranslations.helmetOfSalvation: 'Casco de la Salvación',
      AppTranslations.breastplateOfRighteousness: 'Coraza de Justicia',
      AppTranslations.beltOfTruth: 'Cinturón de Verdad',
      AppTranslations.shoesOfPeace: 'Calzado de Paz',
      AppTranslations.shieldOfFaith: 'Escudo de Fe',
      AppTranslations.swordOfSpirit: 'Espada del Espíritu',
      AppTranslations.armorPractice: 'Práctica de Armadura',
      AppTranslations.armorAdvice: 'Consejo de Armadura',

      // Practice Screens
      AppTranslations.practice: 'Práctica',
      AppTranslations.writing: 'Escritura',
      AppTranslations.dragAndDrop: 'Arrastrar y Soltar',
      AppTranslations.audio: 'Audio',
      AppTranslations.checkAnswer: 'Verificar Respuesta',
      AppTranslations.correct: '¡Correcto!',
      AppTranslations.incorrect: 'Incorrecto',
      AppTranslations.tryAgain: 'Intentar de Nuevo',
      AppTranslations.excellent: '¡Excelente!',
      AppTranslations.goodJob: '¡Buen Trabajo!',

      // Profile
      AppTranslations.createProfile: 'Crear Perfil',
      AppTranslations.editProfile: 'Editar Perfil',
      AppTranslations.name: 'Nombre',
      AppTranslations.age: 'Edad',
      AppTranslations.favoriteVerse: 'Versículo Favorito',
      AppTranslations.profileCreated: 'Perfil Creado',
      AppTranslations.profileUpdated: 'Perfil Actualizado',

      // Settings
      AppTranslations.notifications: 'Notificaciones',
      AppTranslations.theme: 'Tema',
      AppTranslations.privacy: 'Privacidad',
      AppTranslations.about: 'Acerca de',
      AppTranslations.version: 'Versión',

      // Permissions
      AppTranslations.cameraPermission: 'Permiso de Cámara',
      AppTranslations.photoPermission: 'Permiso de Fotos',
      AppTranslations.permissionRequired: 'Permiso Requerido',
      AppTranslations.permissionDenied: 'Permiso Denegado',
      AppTranslations.openSettings: 'Abrir Configuración',

      // Bible Verses
      AppTranslations.verseOfTheDay: 'Versículo del Día',
      AppTranslations.randomVerse: 'Versículo Aleatorio',
      AppTranslations.addToFavorites: 'Agregar a Favoritos',
      AppTranslations.shareVerse: 'Compartir Versículo',
      AppTranslations.saveImage: 'Guardar Imagen',
      AppTranslations.verseSaved: 'Versículo Guardado',

      // Badges
      AppTranslations.badges: 'Insignias',
      AppTranslations.noBadgesAvailable: 'No hay insignias disponibles',

      // Authentication
      AppTranslations.loginSubtitle: 'Inicia sesión para continuar tu viaje bíblico',
      AppTranslations.signingIn: 'Iniciando sesión...',
      AppTranslations.signInWithGoogle: 'Iniciar sesión con Google',
      AppTranslations.loginTerms: 'Al iniciar sesión, aceptas nuestros Términos de Servicio y Política de Privacidad',
      AppTranslations.signInFailed: 'Error al iniciar sesión. Por favor, inténtalo de nuevo.',
      AppTranslations.signInError: 'Error de inicio de sesión',

      // Navigation
      AppTranslations.more: 'Más',
      AppTranslations.verses: 'Versículos',
      AppTranslations.memorization: 'Memorización',
      AppTranslations.armor: 'Armadura',
      AppTranslations.notes: 'Notas',
      AppTranslations.groups: 'Grupos',

      // Errors
      AppTranslations.networkError: 'Error de Red',
      AppTranslations.apiError: 'Error de API',
      AppTranslations.unknownError: 'Error Desconocido',
      AppTranslations.noInternetConnection: 'Sin Conexión a Internet',
    },
    'fr': {
      // Navigation & General
      AppTranslations.appTitle: 'App Biblique',
      AppTranslations.home: 'Accueil',
      AppTranslations.profile: 'Profil',
      AppTranslations.settings: 'Paramètres',
      AppTranslations.back: 'Retour',
      AppTranslations.next: 'Suivant',
      AppTranslations.previous: 'Précédent',
      AppTranslations.done: 'Terminé',
      AppTranslations.cancel: 'Annuler',
      AppTranslations.save: 'Sauvegarder',
      AppTranslations.delete: 'Supprimer',
      AppTranslations.edit: 'Modifier',
      AppTranslations.share: 'Partager',
      AppTranslations.refresh: 'Actualiser',
      AppTranslations.loading: 'Chargement...',
      AppTranslations.error: 'Erreur',
      AppTranslations.success: 'Succès',
      AppTranslations.retry: 'Réessayer',

      // Home Screen
      AppTranslations.welcome: 'Bienvenue',
      AppTranslations.dailyVerse: 'Verset du Jour',
      AppTranslations.armorOfGod: 'Armure de Dieu',
      AppTranslations.auditoryPractice: 'Pratique Auditive',
      AppTranslations.verses: 'Versets',
      AppTranslations.language: 'Langue',

      // Armor of God
      AppTranslations.helmetOfSalvation: 'Casque du Salut',
      AppTranslations.breastplateOfRighteousness: 'Cuirasse de Justice',
      AppTranslations.beltOfTruth: 'Ceinture de Vérité',
      AppTranslations.shoesOfPeace: 'Chaussures de Paix',
      AppTranslations.shieldOfFaith: 'Bouclier de Foi',
      AppTranslations.swordOfSpirit: 'Épée de l\'Esprit',
      AppTranslations.armorPractice: 'Pratique d\'Armure',
      AppTranslations.armorAdvice: 'Conseil d\'Armure',

      // Practice Screens
      AppTranslations.practice: 'Pratique',
      AppTranslations.writing: 'Écriture',
      AppTranslations.dragAndDrop: 'Glisser-Déposer',
      AppTranslations.audio: 'Audio',
      AppTranslations.checkAnswer: 'Vérifier la Réponse',
      AppTranslations.correct: 'Correct !',
      AppTranslations.incorrect: 'Incorrect',
      AppTranslations.tryAgain: 'Réessayer',
      AppTranslations.excellent: 'Excellent !',
      AppTranslations.goodJob: 'Bon Travail !',

      // Profile
      AppTranslations.createProfile: 'Créer un Profil',
      AppTranslations.editProfile: 'Modifier le Profil',
      AppTranslations.name: 'Nom',
      AppTranslations.age: 'Âge',
      AppTranslations.favoriteVerse: 'Verset Favori',
      AppTranslations.profileCreated: 'Profil Créé',
      AppTranslations.profileUpdated: 'Profil Mis à Jour',

      // Settings
      AppTranslations.notifications: 'Notifications',
      AppTranslations.theme: 'Thème',
      AppTranslations.privacy: 'Confidentialité',
      AppTranslations.about: 'À Propos',
      AppTranslations.version: 'Version',

      // Permissions
      AppTranslations.cameraPermission: 'Permission Caméra',
      AppTranslations.photoPermission: 'Permission Photos',
      AppTranslations.permissionRequired: 'Permission Requise',
      AppTranslations.permissionDenied: 'Permission Refusée',
      AppTranslations.openSettings: 'Ouvrir les Paramètres',

      // Bible Verses
      AppTranslations.verseOfTheDay: 'Verset du Jour',
      AppTranslations.randomVerse: 'Verset Aléatoire',
      AppTranslations.addToFavorites: 'Ajouter aux Favoris',
      AppTranslations.shareVerse: 'Partager le Verset',
      AppTranslations.saveImage: 'Sauvegarder l\'Image',
      AppTranslations.verseSaved: 'Verset Sauvegardé',

      // Badges
      AppTranslations.badges: 'Badges',
      AppTranslations.noBadgesAvailable: 'Aucun badge disponible',

      // Authentication
      AppTranslations.loginSubtitle: 'Connectez-vous pour continuer votre parcours biblique',
      AppTranslations.signingIn: 'Connexion en cours...',
      AppTranslations.signInWithGoogle: 'Se connecter avec Google',
      AppTranslations.loginTerms: 'En vous connectant, vous acceptez nos Conditions d\'utilisation et Politique de confidentialité',
      AppTranslations.signInFailed: 'Échec de la connexion. Veuillez réessayer.',
      AppTranslations.signInError: 'Erreur de connexion',

      // Navigation
      AppTranslations.more: 'Plus',
      AppTranslations.verses: 'Versets',
      AppTranslations.memorization: 'Mémorisation',
      AppTranslations.armor: 'Armure',
      AppTranslations.notes: 'Notes',
      AppTranslations.groups: 'Groupes',

      // Errors
      AppTranslations.networkError: 'Erreur de Réseau',
      AppTranslations.apiError: 'Erreur API',
      AppTranslations.unknownError: 'Erreur Inconnue',
      AppTranslations.noInternetConnection: 'Pas de Connexion Internet',
    },
    'it': {
      // Navigation & General
      AppTranslations.appTitle: 'App Biblica',
      AppTranslations.home: 'Home',
      AppTranslations.profile: 'Profilo',
      AppTranslations.settings: 'Impostazioni',
      AppTranslations.back: 'Indietro',
      AppTranslations.next: 'Avanti',
      AppTranslations.previous: 'Precedente',
      AppTranslations.done: 'Fatto',
      AppTranslations.cancel: 'Annulla',
      AppTranslations.save: 'Salva',
      AppTranslations.delete: 'Elimina',
      AppTranslations.edit: 'Modifica',
      AppTranslations.share: 'Condividi',
      AppTranslations.refresh: 'Aggiorna',
      AppTranslations.loading: 'Caricamento...',
      AppTranslations.error: 'Errore',
      AppTranslations.success: 'Successo',
      AppTranslations.retry: 'Riprova',

      // Home Screen
      AppTranslations.welcome: 'Benvenuto',
      AppTranslations.dailyVerse: 'Versetto del Giorno',
      AppTranslations.armorOfGod: 'Armatura di Dio',
      AppTranslations.auditoryPractice: 'Pratica Auditiva',
      AppTranslations.verses: 'Versetti',
      AppTranslations.language: 'Lingua',

      // Armor of God
      AppTranslations.helmetOfSalvation: 'Elmo della Salvezza',
      AppTranslations.breastplateOfRighteousness: 'Corazza della Giustizia',
      AppTranslations.beltOfTruth: 'Cintura della Verità',
      AppTranslations.shoesOfPeace: 'Calzari della Pace',
      AppTranslations.shieldOfFaith: 'Scudo della Fede',
      AppTranslations.swordOfSpirit: 'Spada dello Spirito',
      AppTranslations.armorPractice: 'Pratica dell\'Armatura',
      AppTranslations.armorAdvice: 'Consiglio dell\'Armatura',

      // Practice Screens
      AppTranslations.practice: 'Pratica',
      AppTranslations.writing: 'Scrittura',
      AppTranslations.dragAndDrop: 'Trascina e Rilascia',
      AppTranslations.audio: 'Audio',
      AppTranslations.checkAnswer: 'Verifica Risposta',
      AppTranslations.correct: 'Corretto!',
      AppTranslations.incorrect: 'Sbagliato',
      AppTranslations.tryAgain: 'Riprova',
      AppTranslations.excellent: 'Eccellente!',
      AppTranslations.goodJob: 'Ottimo Lavoro!',

      // Profile
      AppTranslations.createProfile: 'Crea Profilo',
      AppTranslations.editProfile: 'Modifica Profilo',
      AppTranslations.name: 'Nome',
      AppTranslations.age: 'Età',
      AppTranslations.favoriteVerse: 'Versetto Preferito',
      AppTranslations.profileCreated: 'Profilo Creato',
      AppTranslations.profileUpdated: 'Profilo Aggiornato',

      // Settings
      AppTranslations.notifications: 'Notifiche',
      AppTranslations.theme: 'Tema',
      AppTranslations.privacy: 'Privacy',
      AppTranslations.about: 'Informazioni',
      AppTranslations.version: 'Versione',

      // Permissions
      AppTranslations.cameraPermission: 'Permesso Fotocamera',
      AppTranslations.photoPermission: 'Permesso Foto',
      AppTranslations.permissionRequired: 'Permesso Richiesto',
      AppTranslations.permissionDenied: 'Permesso Negato',
      AppTranslations.openSettings: 'Apri Impostazioni',

      // Bible Verses
      AppTranslations.verseOfTheDay: 'Versetto del Giorno',
      AppTranslations.randomVerse: 'Versetto Casuale',
      AppTranslations.addToFavorites: 'Aggiungi ai Preferiti',
      AppTranslations.shareVerse: 'Condividi Versetto',
      AppTranslations.saveImage: 'Salva Immagine',
      AppTranslations.verseSaved: 'Versetto Salvato',

      // Badges
      AppTranslations.badges: 'Badge',
      AppTranslations.noBadgesAvailable: 'Nessun badge disponibile',

      // Authentication
      AppTranslations.loginSubtitle: 'Accedi per continuare il tuo viaggio biblico',
      AppTranslations.signingIn: 'Accesso in corso...',
      AppTranslations.signInWithGoogle: 'Accedi con Google',
      AppTranslations.loginTerms: 'Accedendo, accetti i nostri Termini di Servizio e Politica sulla Privacy',
      AppTranslations.signInFailed: 'Accesso fallito. Riprova.',
      AppTranslations.signInError: 'Errore di accesso',

      // Navigation
      AppTranslations.more: 'Altro',
      AppTranslations.verses: 'Versetti',
      AppTranslations.memorization: 'Memorizzazione',
      AppTranslations.armor: 'Armatura',
      AppTranslations.notes: 'Note',
      AppTranslations.groups: 'Gruppi',

      // Errors
      AppTranslations.networkError: 'Errore di Rete',
      AppTranslations.apiError: 'Errore API',
      AppTranslations.unknownError: 'Errore Sconosciuto',
      AppTranslations.noInternetConnection: 'Nessuna Connessione Internet',
    },
  };

  /// Get translation for current language
  static String get(String key, {String? languageCode}) {
    final lang = languageCode ?? LanguageService.instance.currentLanguageCode;
    final translations = _translations[lang] ?? _translations['en']!;
    return translations[key] ?? key;
  }

  /// Get translation with parameters
  static String getWithParams(String key, Map<String, String> params, {String? languageCode}) {
    String translation = get(key, languageCode: languageCode);
    
    params.forEach((key, value) {
      translation = translation.replaceAll('{$key}', value);
    });
    
    return translation;
  }
}
