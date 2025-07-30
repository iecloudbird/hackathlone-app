// Asset path constants for centralized asset management
class AppAssets {
  // Images
  static const String _imagesPath = 'assets/images';
  static const String logo = '$_imagesPath/logo';
  static const String motif = '$_imagesPath/motif.png';
  static const String dayNight = '$_imagesPath/dayNnight.png';

  // Fonts
  static const String _fontsPath = 'assets/fonts';
  static const String firaSansBlack = '$_fontsPath/FiraSans-Black.ttf';
  static const String firaSansBold = '$_fontsPath/FiraSans-Bold.ttf';
  static const String overpassBold = '$_fontsPath/Overpass-Bold.ttf';
  static const String overpassRegular = '$_fontsPath/Overpass-Regular.ttf';

  // Environment (this will replace by bash_profile soon
  static const String envFile = 'assets/.env';
}
