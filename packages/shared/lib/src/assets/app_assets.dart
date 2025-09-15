/// Application assets
class AppAssets {
  // Images
  static const String imagesPath = 'assets/images/';
  static const String logo = '${imagesPath}logo.png';
  static const String logoWhite = '${imagesPath}logo_white.png';
  static const String placeholderPet = '${imagesPath}placeholder_pet.png';
  static const String placeholderUser = '${imagesPath}placeholder_user.png';
  static const String placeholderClinic = '${imagesPath}placeholder_clinic.png';
  static const String backgroundPattern = '${imagesPath}background_pattern.png';

  // Icons
  static const String iconsPath = 'assets/icons/';
  static const String icPet = '${iconsPath}ic_pet.svg';
  static const String icMedical = '${iconsPath}ic_medical.svg';
  static const String icClinic = '${iconsPath}ic_clinic.svg';
  static const String icUser = '${iconsPath}ic_user.svg';
  static const String icAppointment = '${iconsPath}ic_appointment.svg';
  static const String icPrescription = '${iconsPath}ic_prescription.svg';
  static const String icReport = '${iconsPath}ic_report.svg';
  static const String icNotification = '${iconsPath}ic_notification.svg';
  static const String icSettings = '${iconsPath}ic_settings.svg';

  // Fonts
  static const String fontsPath = 'assets/fonts/';
  static const String fontInterRegular = '${fontsPath}Inter-Regular.ttf';
  static const String fontInterMedium = '${fontsPath}Inter-Medium.ttf';
  static const String fontInterSemiBold = '${fontsPath}Inter-SemiBold.ttf';
  static const String fontInterBold = '${fontsPath}Inter-Bold.ttf';

  // Animations (Lottie)
  static const String animationsPath = 'assets/animations/';
  static const String loadingAnimation = '${animationsPath}loading.json';
  static const String successAnimation = '${animationsPath}success.json';
  static const String errorAnimation = '${animationsPath}error.json';
  static const String emptyAnimation = '${animationsPath}empty.json';

  // Sounds
  static const String soundsPath = 'assets/sounds/';
  static const String notificationSound = '${soundsPath}notification.mp3';
  static const String successSound = '${soundsPath}success.mp3';
  static const String errorSound = '${soundsPath}error.mp3';

  // Veterinary specific assets
  static const String petBreedsPath = 'assets/images/pet_breeds/';
  static const String medicalIconsPath = 'assets/icons/medical/';

  // Get asset path with package prefix
  static String getAssetPath(String asset, {String? package}) {
    if (package != null) {
      return 'packages/$package/$asset';
    }
    return asset;
  }

  // Check if asset exists (for debugging)
  static bool assetExists(String asset) => true;

  // Get placeholder image based on type
  static String getPlaceholderImage(String type) {
    switch (type.toLowerCase()) {
      case 'pet':
      case 'animal':
        return placeholderPet;
      case 'user':
      case 'person':
        return placeholderUser;
      case 'clinic':
      case 'hospital':
        return placeholderClinic;
      default:
        return placeholderUser;
    }
  }

  // Get icon based on medical type
  static String getMedicalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return icAppointment;
      case 'prescription':
        return icPrescription;
      case 'report':
        return icReport;
      case 'notification':
        return icNotification;
      default:
        return icMedical;
    }
  }

  // Get pet breed image
  static String getPetBreedImage(String breed) => '$petBreedsPath${breed.toLowerCase().replaceAll(' ', '_')}.png';

  // Get medical specialty icon
  static String getMedicalSpecialtyIcon(String specialty) =>
      '$medicalIconsPath${specialty.toLowerCase().replaceAll(' ', '_')}.svg';
}
