import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'ParkiSense',
      'get_started': 'Get Started',
      'next': 'Next',
      'skip': 'Skip',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'back': 'Back',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Onboarding
      'onboarding_voice_title': 'Voice-Based Screening',
      'onboarding_voice_desc': 'Record your voice in seconds and get instant analysis for Parkinson\'s disease risk assessment.',
      'onboarding_ai_title': 'Powered by AI',
      'onboarding_ai_desc': 'Our machine learning models analyze voice patterns to detect early signs of Parkinson\'s disease with 85%+ accuracy.',
      'onboarding_privacy_title': 'Your Privacy Matters',
      'onboarding_privacy_desc': 'All your health data is encrypted and stored securely. You control what gets shared.',
      'onboarding_ready_title': 'Ready to Get Started?',
      'onboarding_ready_desc': 'Create an account or log in to begin your screening journey.',
      
      // Welcome
      'welcome_title': 'Parkinson\'s Disease Voice Screening',
      'welcome_subtitle': 'Detect early signs through advanced voice analysis',
      'service_voice_title': 'Instant Voice Screening',
      'service_voice_desc': 'Record a quick voice sample for analysis',
      'service_ai_title': 'AI-Powered Analysis',
      'service_ai_desc': 'Twin models (SVM + CNN) for accurate detection',
      'service_security_title': 'Secure Health Records',
      'service_security_desc': 'All data encrypted and stored safely',
      'service_insights_title': 'Professional Insights',
      'service_insights_desc': 'Share results with doctors for expert consultation',
      'login': 'Login',
      'signup': 'Sign Up',
      'privacy_policy': 'Privacy Policy',
      'about_us': 'About Us',
      
      // Auth
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'full_name': 'Full Name',
      'forgot_password': 'Forgot Password?',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account?',
      'sign_in_google': 'Sign in with Google',
      
      // Dashboard
      'welcome': 'Welcome',
      'health_status': 'YOUR HEALTH STATUS',
      'total_screenings': 'Total Screenings',
      'last_result': 'Last Result',
      'trend': 'Trend',
      'stable': 'Stable',
      'quick_actions': 'QUICK ACTIONS',
      'record_now': 'Record Now',
      'start_screening': 'Start Screening',
      'view_history': 'View History',
      'past_screenings': 'Past Screenings',
      'recent_screenings': 'RECENT SCREENINGS',
      'view_all': 'View All',
      'health_tips': 'HEALTH TIPS',
      'tip_voice': 'Maintain good speaking habits daily',
      'tip_voice_desc': 'Regular voice exercises help maintain vocal health.',
      'tip_screening': 'Regular screening helps early detection',
      'tip_screening_desc': 'Monthly screenings can detect changes early.',
      
      // Results
      'healthy': 'Healthy',
      'at_risk': 'At Risk',
      'confidence': 'Confidence',
      'svm_model': 'SVM Model',
      'cnn_model': 'CNN Model',
      'acoustic_features': 'Acoustic Features',
      
      // History
      'screening_history': 'Screening History',
      'all': 'All',
      'filter_healthy': 'Healthy',
      'filter_at_risk': 'At Risk',
      'no_screenings': 'No screenings found',
      'view_details': 'View Details',
      'share': 'Share',
      'export_pdf': 'Export PDF',
      
      // Profile
      'profile_settings': 'Profile & Settings',
      'account_settings': 'ACCOUNT SETTINGS',
      'change_name': 'Change Name',
      'change_email': 'Change Email',
      'change_password': 'Change Password',
      'two_factor': 'Two-Factor Authentication',
      'app_settings': 'APP SETTINGS',
      'dark_mode': 'Dark Mode',
      'switch_dark_theme': 'Switch to dark theme',
      'notifications': 'Notifications',
      'manage_notifications': 'Manage push notifications',
      'language': 'Language',
      'auto_backup': 'Auto-backup to Cloud',
      'auto_backup_desc': 'Automatically backup your data',
      'data_management': 'DATA MANAGEMENT',
      'export_data': 'Export My Data',
      'export_data_desc': 'Download all your data as JSON',
      'download_pdf': 'Download Records (PDF)',
      'download_pdf_desc': 'Export screening records as PDF',
      'delete_account': 'Delete Account',
      'delete_account_desc': 'Permanently delete your account',
      'help_support': 'HELP & SUPPORT',
      'faqs': 'FAQs',
      'faqs_desc': 'Frequently asked questions',
      'contact_support': 'Contact Support',
      'contact_support_desc': 'Get help from our team',
      'privacy_policy_link': 'Privacy Policy',
      'privacy_policy_desc': 'Read our privacy policy',
      'terms_of_service': 'Terms of Service',
      'terms_of_service_desc': 'Read our terms of service',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'verified_user': 'Verified User',
      
      // Sharing
      'share_provider': 'Share with Healthcare Provider',
      'scan_to_view': 'Scan to View Results',
      'share_desc': 'Healthcare providers can view this screening without logging in.',
      'link_expires': 'Link expires in 7 days',
      'copy_link': 'Copy Link',
      'save_qr': 'Save QR',
      'share_message': 'View my Parkinson\'s screening results',
      
      // Errors
      'error_generic': 'An error occurred. Please try again.',
      'error_network': 'Network error. Please check your connection.',
      'error_auth': 'Authentication failed. Please check your credentials.',
    },
    'fr': {
      // Common
      'app_name': 'ParkiSense',
      'get_started': 'Commencer',
      'next': 'Suivant',
      'skip': 'Passer',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'close': 'Fermer',
      'back': 'Retour',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      
      // Onboarding
      'onboarding_voice_title': 'Dépistage Vocal',
      'onboarding_voice_desc': 'Enregistrez votre voix en quelques secondes et obtenez une analyse instantanée pour l\'évaluation du risque de maladie de Parkinson.',
      'onboarding_ai_title': 'Alimenté par l\'IA',
      'onboarding_ai_desc': 'Nos modèles d\'apprentissage automatique analysent les modèles vocaux pour détecter les premiers signes de la maladie de Parkinson avec une précision de 85%+.',
      'onboarding_privacy_title': 'Votre Vie Privée Compte',
      'onboarding_privacy_desc': 'Toutes vos données de santé sont cryptées et stockées en toute sécurité. Vous contrôlez ce qui est partagé.',
      'onboarding_ready_title': 'Prêt à Commencer?',
      'onboarding_ready_desc': 'Créez un compte ou connectez-vous pour commencer votre parcours de dépistage.',
      
      // Welcome
      'welcome_title': 'Dépistage Vocal de la Maladie de Parkinson',
      'welcome_subtitle': 'Détectez les premiers signes grâce à une analyse vocale avancée',
      'service_voice_title': 'Dépistage Vocal Instantané',
      'service_voice_desc': 'Enregistrez un échantillon vocal rapide pour analyse',
      'service_ai_title': 'Analyse Alimentée par l\'IA',
      'service_ai_desc': 'Modèles jumeaux (SVM + CNN) pour une détection précise',
      'service_security_title': 'Dossiers de Santé Sécurisés',
      'service_security_desc': 'Toutes les données cryptées et stockées en toute sécurité',
      'service_insights_title': 'Avis Professionnels',
      'service_insights_desc': 'Partagez les résultats avec les médecins pour une consultation experte',
      'login': 'Connexion',
      'signup': 'Inscription',
      'privacy_policy': 'Politique de Confidentialité',
      'about_us': 'À Propos',
      
      // Auth
      'email': 'Email',
      'password': 'Mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      'full_name': 'Nom complet',
      'forgot_password': 'Mot de passe oublié?',
      'no_account': 'Vous n\'avez pas de compte?',
      'have_account': 'Vous avez déjà un compte?',
      'sign_in_google': 'Se connecter avec Google',
      
      // Dashboard
      'welcome': 'Bienvenue',
      'health_status': 'VOTRE ÉTAT DE SANTÉ',
      'total_screenings': 'Total des Dépistages',
      'last_result': 'Dernier Résultat',
      'trend': 'Tendance',
      'stable': 'Stable',
      'quick_actions': 'ACTIONS RAPIDES',
      'record_now': 'Enregistrer Maintenant',
      'start_screening': 'Commencer le Dépistage',
      'view_history': 'Voir l\'Historique',
      'past_screenings': 'Dépistages Passés',
      'recent_screenings': 'DÉPISTAGES RÉCENTS',
      'view_all': 'Voir Tout',
      'health_tips': 'CONSEILS DE SANTÉ',
      'tip_voice': 'Maintenez de bonnes habitudes de parole quotidiennement',
      'tip_voice_desc': 'Les exercices vocaux réguliers aident à maintenir la santé vocale.',
      'tip_screening': 'Le dépistage régulier aide à la détection précoce',
      'tip_screening_desc': 'Les dépistages mensuels peuvent détecter les changements tôt.',
      
      // Results
      'healthy': 'Sain',
      'at_risk': 'À Risque',
      'confidence': 'Confiance',
      'svm_model': 'Modèle SVM',
      'cnn_model': 'Modèle CNN',
      'acoustic_features': 'Caractéristiques Acoustiques',
      
      // History
      'screening_history': 'Historique des Dépistages',
      'all': 'Tous',
      'filter_healthy': 'Sain',
      'filter_at_risk': 'À Risque',
      'no_screenings': 'Aucun dépistage trouvé',
      'view_details': 'Voir les Détails',
      'share': 'Partager',
      'export_pdf': 'Exporter PDF',
      
      // Profile
      'profile_settings': 'Profil et Paramètres',
      'account_settings': 'PARAMÈTRES DU COMPTE',
      'change_name': 'Changer le Nom',
      'change_email': 'Changer l\'Email',
      'change_password': 'Changer le Mot de Passe',
      'two_factor': 'Authentification à Deux Facteurs',
      'app_settings': 'PARAMÈTRES DE L\'APPLICATION',
      'dark_mode': 'Mode Sombre',
      'switch_dark_theme': 'Passer au thème sombre',
      'notifications': 'Notifications',
      'manage_notifications': 'Gérer les notifications push',
      'language': 'Langue',
      'auto_backup': 'Sauvegarde Automatique dans le Cloud',
      'auto_backup_desc': 'Sauvegardez automatiquement vos données',
      'data_management': 'GESTION DES DONNÉES',
      'export_data': 'Exporter Mes Données',
      'export_data_desc': 'Télécharger toutes vos données en JSON',
      'download_pdf': 'Télécharger les Enregistrements (PDF)',
      'download_pdf_desc': 'Exporter les enregistrements de dépistage en PDF',
      'delete_account': 'Supprimer le Compte',
      'delete_account_desc': 'Supprimer définitivement votre compte',
      'help_support': 'AIDE ET SUPPORT',
      'faqs': 'FAQ',
      'faqs_desc': 'Questions fréquemment posées',
      'contact_support': 'Contacter le Support',
      'contact_support_desc': 'Obtenir de l\'aide de notre équipe',
      'privacy_policy_link': 'Politique de Confidentialité',
      'privacy_policy_desc': 'Lire notre politique de confidentialité',
      'terms_of_service': 'Conditions d\'Utilisation',
      'terms_of_service_desc': 'Lire nos conditions d\'utilisation',
      'logout': 'Déconnexion',
      'logout_confirm': 'Êtes-vous sûr de vouloir vous déconnecter?',
      'verified_user': 'Utilisateur Vérifié',
      
      // Sharing
      'share_provider': 'Partager avec un Professionnel de Santé',
      'scan_to_view': 'Scannez pour Voir les Résultats',
      'share_desc': 'Les professionnels de santé peuvent voir ce dépistage sans se connecter.',
      'link_expires': 'Le lien expire dans 7 jours',
      'copy_link': 'Copier le Lien',
      'save_qr': 'Sauvegarder QR',
      'share_message': 'Voir mes résultats de dépistage Parkinson',
      
      // Errors
      'error_generic': 'Une erreur s\'est produite. Veuillez réessayer.',
      'error_network': 'Erreur réseau. Vérifiez votre connexion.',
      'error_auth': 'Échec de l\'authentification. Vérifiez vos identifiants.',
    },
    'sw': {
      // Common
      'app_name': 'ParkiSense',
      'get_started': 'Anza',
      'next': 'Ifuatayo',
      'skip': 'Ruka',
      'cancel': 'Ghairi',
      'save': 'Hifadhi',
      'delete': 'Futa',
      'edit': 'Hariri',
      'close': 'Funga',
      'back': 'Rudi',
      'loading': 'Inapakia...',
      'error': 'Kosa',
      'success': 'Mafanikio',
      
      // Onboarding
      'onboarding_voice_title': 'Uchunguzi wa Sauti',
      'onboarding_voice_desc': 'Rekodi sauti yako kwa sekunde na pata uchambuzi wa papo hapo kwa tathmini ya hatari ya ugonjwa wa Parkinson.',
      'onboarding_ai_title': 'Inaendeshwa na AI',
      'onboarding_ai_desc': 'Mifano yetu ya kujifunza kwa mashine inachambua mitindo ya sauti kutambua ishara za awali za ugonjwa wa Parkinson kwa usahihi wa zaidi ya 85%.',
      'onboarding_privacy_title': 'Faragha Yako Ni Muhimu',
      'onboarding_privacy_desc': 'Data zote za afya zako zimefichwa na kuhifadhiwa salama. Wewe unadhibitu kinachoshirikiwa.',
      'onboarding_ready_title': 'Uko Tayari Kuanza?',
      'onboarding_ready_desc': 'Tengeneza akaunti au ingia kuanza safari yako uchunguzi.',
      
      // Welcome
      'welcome_title': 'Uchunguzi wa Sauti wa Ugonjwa wa Parkinson',
      'welcome_subtitle': 'Tambua ishara za awali kupitia uchambuzi wa sauti wa kiendevu',
      'service_voice_title': 'Uchunguzi wa Sauti wa Papo Hapo',
      'service_voice_desc': 'Rekodi sampuli ya sauti kwa uchambuzi',
      'service_ai_title': 'Uchambuzi Inaendeshwa na AI',
      'service_ai_desc': 'Mifano pacha (SVM + CNN) kwa utambuzi sahihi',
      'service_security_title': 'Rekodi za Afya Salama',
      'service_security_desc': 'Data zote zimefichwa na kuhifadhiwa salama',
      'service_insights_title': 'Mawazo ya Wataalamu',
      'service_insights_desc': 'Shiriki matokeo na madaktari kwa ushauri wa kitaalam',
      'login': 'Ingia',
      'signup': 'Jiunge',
      'privacy_policy': 'Sera ya Faragha',
      'about_us': 'Kuhusu Sisi',
      
      // Auth
      'email': 'Barua pepe',
      'password': 'Nenosiri',
      'confirm_password': 'Thibitisha Nenosiri',
      'full_name': 'Jina Kamili',
      'forgot_password': 'Umesahau Nenosiri?',
      'no_account': 'Huna akaunti?',
      'have_account': 'Tayari una akaunti?',
      'sign_in_google': 'Ingia na Google',
      
      // Dashboard
      'welcome': 'Karibu',
      'health_status': 'HALI YAKO YA AFYA',
      'total_screenings': 'Jumla ya Uchunguzi',
      'last_result': 'Matokeo ya Mwisho',
      'trend': 'Mwelekeo',
      'stable': 'Imara',
      'quick_actions': 'VITENDO VYA HARAKA',
      'record_now': 'Rekodi Sasa',
      'start_screening': 'Anza Uchunguzi',
      'view_history': 'Angalia Historia',
      'past_screenings': 'Uchunguzi Uliopita',
      'recent_screenings': 'UCHUNGUZI WA Hivi Karibuni',
      'view_all': 'Angalia Zote',
      'health_tips': 'USHAURI WA AFYA',
      'tip_voice': 'Dumisha tabia nzuri za kuzungumza kila siku',
      'tip_voice_desc': 'Mazoezi ya sauti ya mara kwa mara husaidia kudumisha afya ya sauti.',
      'tip_screening': 'Uchunguzi wa mara kwa mara husaidia utambuzi wa awali',
      'tip_screening_desc': 'Uchunguzi wa kila mwezi unaweza kutambua mabadiliko mapema.',
      
      // Results
      'healthy': 'Afya',
      'at_risk': 'Katika Hatari',
      'confidence': 'Uaminifu',
      'svm_model': 'Mfano wa SVM',
      'cnn_model': 'Mfano wa CNN',
      'acoustic_features': 'Sifa za Sauti',
      
      // History
      'screening_history': 'Historia ya Uchunguzi',
      'all': 'Yote',
      'filter_healthy': 'Afya',
      'filter_at_risk': 'Katika Hatari',
      'no_screenings': 'Hakuna uchunguzi uliopatikana',
      'view_details': 'Angalia Maelezo',
      'share': 'Shiriki',
      'export_pdf': 'Hamisha PDF',
      
      // Profile
      'profile_settings': 'Wasiliana na Mipangilio',
      'account_settings': 'MIPANGILIO YA AKAUNTI',
      'change_name': 'Badilisha Jina',
      'change_email': 'Badilisha Barua Pepe',
      'change_password': 'Badilisha Nenosiri',
      'two_factor': 'Uthibitisho wa Viwango Viwili',
      'app_settings': 'MIPANGILIO YA PROGRAMU',
      'dark_mode': 'Hali ya Giza',
      'switch_dark_theme': 'Badilisha kwa mandhari ya giza',
      'notifications': 'Arifa',
      'manage_notifications': 'Dhibiti arifa za push',
      'language': 'Lugha',
      'auto_backup': 'Hifadhi ya Kiotomatiki kwenye Cloud',
      'auto_backup_desc': 'Hifadhi data zako kiotomatiki',
      'data_management': 'USIMAMIZI WA DATA',
      'export_data': 'Hamisha Data Yangu',
      'export_data_desc': 'Pakua data zako zote kama JSON',
      'download_pdf': 'Pakua Rekodi (PDF)',
      'download_pdf_desc': 'Hamisha rekodi za uchunguzi kama PDF',
      'delete_account': 'Futa Akaunti',
      'delete_account_desc': 'Futa akaunti yako kwa kudumu',
      'help_support': 'MSAADA NA USHIRIKA',
      'faqs': 'FAQ',
      'faqs_desc': 'Maswali yanayoulizwa mara nyingi',
      'contact_support': 'Wasiliana na Msaada',
      'contact_support_desc': 'Pata msaada kutoka kwa timu yetu',
      'privacy_policy_link': 'Sera ya Faragha',
      'privacy_policy_desc': 'Soma sera yetu ya faragha',
      'terms_of_service': 'Masharti ya Huduma',
      'terms_of_service_desc': 'Soma masharti yetu ya huduma',
      'logout': 'Ondoka',
      'logout_confirm': 'Una uhakika unataka kuondoka?',
      'verified_user': 'Mtumiaji Thibitishwa',
      
      // Sharing
      'share_provider': 'Shiriki na Mtaalamu wa Afya',
      'scan_to_view': 'Changanua kuona Matokeo',
      'share_desc': 'Wataalamu wa afya wanaweza kuona uchunguzi huu bila kuingia.',
      'link_expires': 'Kiungo kitatoka baada ya siku 7',
      'copy_link': 'Nakili Kiungo',
      'save_qr': 'Hifadhi QR',
      'share_message': 'Angalia matokeo yangu ya uchunguzi wa Parkinson',
      
      // Errors
      'error_generic': 'Kosa imetokea. Tafadhali jaribu tena.',
      'error_network': 'Kosa la mtandao. Tafadhali angalia muunganisho wako.',
      'error_auth': 'Uthibitisho umeshindwa. Tafadhali angalia sifa zako.',
    },
  };

  static const List<String> supportedLanguages = ['en', 'fr', 'sw'];

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'sw':
        return 'Kiswahili';
      default:
        return 'English';
    }
  }

  static String getString(String key, {String languageCode = 'en'}) {
    if (!_localizedValues.containsKey(languageCode)) {
      languageCode = 'en';
    }
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
