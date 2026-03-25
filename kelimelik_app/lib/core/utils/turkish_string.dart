/// Turkish-aware string utilities.
/// Handles the special İ/I ↔ i/ı mapping that standard Dart locale doesn't.
extension TurkishString on String {
  String get turkceUpper =>
      replaceAll('ı', 'I').replaceAll('i', 'İ').toUpperCase();

  String get turkceLower =>
      replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
}

String turkceUpper(String s) => s.turkceUpper;
String turkceLower(String s) => s.turkceLower;
